revalidator = require 'revalidator'
parameters = require '../../json/parameters'
mongoose = require 'mongoose'
nodeGuid = require 'node-guid'
crypto = require 'crypto'
nodemailer = require 'nodemailer'
connect = require 'connect'
consolidate = require 'consolidate'
express = require 'express'

utilities = require '../../js/utilities'
utilities = new utilities
  "templateDir": "../modules"

mongoose.connect parameters.mongodb.path
#mongoose.set 'debug', true
db = mongoose.connection
db.on 'error', console.error.bind(console, 'connection error:')
db.once 'open', ->
  console.log 'mongoose is connected!!!'

userSchema = mongoose.Schema(
  email: String
  password: String
  salt: String
  name: String
  confirmed: Boolean
  transactions: Array
  startDate: Date
  billingDate: Date
  plan: String
  confirmationGuid: String
  resetGuid: String
)

User = mongoose.model 'User', userSchema

userValidator =
  properties:
    email:
      description: 'user email'
      type: 'string'
      format: 'email'
      required: true
    password:
      description: 'user password'
      type: 'string'
      required: true


class UserAPI
  constructor: (app, routes, test) ->
    @app = app
    @routes = routes
    @test = test
    @register()

  register: ->
    that = this
    @app.use express.bodyParser()

    @app.get @routes.base, (req, res) ->
      res.writeHead 200,
        'Content-Type': 'application/json'
      res.end JSON.stringify that.routes

    @app.post @routes.base + @routes.create, (req, res) ->
      that.createUser req, (result, code) ->
        res.writeHead code || 201,
          'Content-Type': 'application/json'
        res.end JSON.stringify result
    @app.get @routes.base + @routes.confirm, (req, res)  ->

      that.confirmUser req.query.email, req.query.confirmationGuid, (error, result) ->
        res.writeHead 302,
          'Content-Type': 'text/html'
          'Location': parameters.routing.redirects.login
        req.session.notification =
          type: if error then 'error' else 'success'
          message: if error then 'Email confirmation failed.  Please try again.' else 'User email confirmed. Please log in.'
        res.end JSON.stringify
          error: error
          result: result

    @app.post @routes.base + @routes.login, (req, res) ->
      that.login req, (result, code) ->
        res.writeHead code || 201,
          'Content-Type': 'application/json'
        res.end JSON.stringify result

    @app.get @routes.base + @routes.email.confirm, (req, res) ->
      email = req.query.email
      guid = req.query.confirmationGuid
      link = 'http://' + req.headers.host + '/api/user/confirm?email=' + email + '&confirmationGuid=' + guid
      res.writeHead 200,
        'Content-Type': 'text/html'
      res.end that.renderConfirmationEmail email, guid, link

    @app.get @routes.base + @routes.get, (req, res) ->
      user = req.session.user

      if user
        res.writeHead 200,
          'Content-Type': 'application/json'
        res.end JSON.stringify user
      else
        res.writeHead 401,
          'Content-Type': 'application/json'
        res.end JSON.stringify
          error: "User could not be found in session"

    @app.post @routes.base + @routes.logOut, (req, res) ->
      req.session.destroy((error) ->
        if error
          res.writeHead 401,
            'Content-Type': 'application/json'
          res.end JSON.stringify
            message: 'Log out failed'
            errors: error
        else
          res.writeHead 200,
            'Content-Type': 'application/json'
          res.end JSON.stringify
            message: 'User logged out'
      )

    @app.post @routes.base + @routes.update, (req, res) ->
      console.log 'time to write an update method!!!'
      console.log 'updating', req.body



  createUser: (req, callback) ->
    that = this
    user = req.body
#    Basic validation
    errors = revalidator.validate user, userValidator
    if errors.valid == false
      callback
        message: "User validation failed"
        errors: errors
      , 401
      return

#   Don't allow duplicate emails
    @findUserByEmail user.email, (error, result) ->
      if error
        callback
          message: "User search failed"
          errors: error
        , 401
        return
      if result.length
        callback
          message: user.email + ' has already registered.'
        , 401
        return

#      Create user
      user = new User user
      user.salt = nodeGuid.new()
      user.password = that.hashPassword user.password, user.salt
      user.confirmed = false
      user.confirmationGuid = nodeGuid.new()
      user.resetGuid = nodeGuid.new()
      user.startDate = new Date()
      user.type = 'seller'
      user.save (error, user) ->
        if error
          return callback
            message: error
          , 401
        that.sendConfirmationEmail req, user.email, user.confirmationGuid, (error, response) ->
          if error
            return callback
              message: 'Confirmation email failed to send.'
            , 500
          callback
            message: 'A confirmation email has been sent to ' + user.email + '.'


  hashPassword: (password, salt) ->
    hash = password
    i = 5
    while (i--)
      hash = crypto.createHmac('sha512', salt).update(hash).digest('hex')
    return hash

  findUserByEmail: (email, callback) ->
    User.find
      email: email
    , callback

  sendConfirmationEmail: (req, email, guid, callback) ->
    link = 'http://' + req.headers.host + '/api/user/confirm?email=' + email + '&confirmationGuid=' + guid

    smtpTransport = nodemailer.createTransport 'SMTP',
      service: 'Gmail'
      auth:
        user: parameters.email.username
        pass: parameters.email.password
    options =
      from: parameters.email.from
      to: email
      subject: parameters.email.confirmation.subject
      text: parameters.email.confirmation.text + ' ' + link
      html: @renderConfirmationEmail email, guid, link
    if @test
      return callback()
    smtpTransport.sendMail options, callback

  renderConfirmationEmail: (email, guid, link) ->
#    map = plates.Map()
#    map.where('href').is('/').insert 'link'
#    return utilities.renderTemplate 'confirmationEmail',
#      email: email
#      link: link
#      'link-id': link
#    , map

  confirmUser: (email, guid, callback) ->
    @findUserByEmail email, (error, result) ->
      if result && result[0] && result[0].confirmationGuid == guid
        result[0].confirmed = true
        result[0].save()
      else
        error =
          message: 'Confirmation tokens did not match.'
      return callback(error, result)

  findUserByID: (id, callback) ->
    User.find
      _id: id
    , callback
    return

  login: (req, callback) ->
    that = this
    email = req.body.email
    password = req.body.password
    @findUserByEmail email, (error, result) ->
      if result && result[0]
        user = result[0]
        hash = that.hashPassword password, user.salt
        if hash == user.password
          req.session.user = user
          return callback
            user: that.cleanUserForClient user
            redirect: req.session.redirect
      callback
        message: 'User not found'
      , 404

  cleanUserForClient: (user) ->
    user.password = null
    user.salt = null
    user.confirmationGuid = null
    user.resetGuid = null
    return user

  removeUser: (id, callback) ->
    @findUserByID(id, (error, result) ->
      if result[0] && result.length == 1
        result[0].remove callback
    )

  redirect: (req, res, next) =>
    if req.session.user || ~parameters.routing.whitelist.indexOf req.url
      next()
      return
    req.session.notification =
      type: 'error'
      message: 'You must be logged in to view that page.'
    req.session.redirect = req.url
    res.writeHead 302,
      'Content-Type': 'text/html'
      'Location': parameters.routing.redirects.login
    res.end JSON.stringify req.session.notification
    return

module.exports = UserAPI
