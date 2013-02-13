revalidator = require 'revalidator'
resourceful = require 'resourceful'
parameters = require '../json/parameters'
mongoose = require 'mongoose'
nodeGuid = require 'node-guid'
crypto = require 'crypto'
nodemailer = require 'nodemailer'
connect = require 'connect'

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
  constructor: (router, routes, test) ->
    @router = router
    @routes = routes
    @test = test
    @register()

  register: ->
    that = this
    @router.post @routes.base + @routes.create, () ->
      res = this.res
      that.createUser this.req, (result, code) ->
        res.writeHead code || 201,
          'Content-Type': 'text/html'
        res.end JSON.stringify result
    @router.get @routes.base + @routes.confirm, () ->
      res = this.res
      req = this.req

      that.confirmUser this.req.query.email, this.req.query.confirmationGuid, (error, result) ->
        res.writeHead 302,
          'Content-Type': 'text/html'
          'Location': parameters.routing.redirects.login
        req.session.notification =
          type: if error then 'error' else 'success'
          message: if error then 'Email confirmation failed.  Please try again.' else 'User email confirmed. Please log in.'
        res.end JSON.stringify
          error: error
          result: result

    @router.post @routes.base + @routes.login, () ->
      res = this.res
      that.login this.req, (result, code) ->
        res.writeHead code || 201,
          'Content-Type': 'text/html'
        res.end JSON.stringify result

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
      html: link
    if @test
      return callback()
    smtpTransport.sendMail options, callback

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
          req.session._id = user._id
          return callback
            user: that.cleanUserForClient user
            redirect: req.session.redirect
      callback
        message: 'User not found'
      , 404
      return
    return

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

  setUser: (req, res, next) =>
    _id = req.session._id
    if _id
      @findUserByID _id, (error, result) ->
        req.user = result[0]
        next()
    else
      next()
  redirect: (req, res, next) =>
    if req.user || ~parameters.routing.whitelist.indexOf req.url
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
