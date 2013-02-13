port = process.argv[2] || 3000;
flatiron = require 'flatiron'
plates = require 'plates'
app = flatiron.app
connect = require 'connect'
parameters = require './json/parameters'

# RequireJS for the server
requirejs = require 'requirejs'
requirejs.config
  nodeRequire: require
  baseUrl: '../assets/scripts/js/'

#  Utility functions
utilities = require './utilities'
utilities = new utilities
  "templateDir": "./assets/templates"



# Instantiate Server
app.use flatiron.plugins.http
app.use flatiron.plugins.static,
  dir: './assets'
  index: true
  dot: true
  url: '/assets'

# Serve index page
app.router.get '/', ->
  headers =
    'Content-Type': 'text/html'
  if this.req.session && this.req.session.notification
    headers['x-notification'] = JSON.stringify this.req.session.notification
  this.res.writeHead 200, headers
  this.res.end utilities.getTemplate 'index'

app.router.get '/notifications', ->
  notification = {}
  if this.req.session && this.req.session.notification
    notification = this.req.session.notification
    this.req.session.notification = null
  this.res.writeHead 200,
    'Content-Type': 'text/plain'
  this.res.end JSON.stringify notification

# Register Modules

apiRoutes = require './json/apiRoutes'
userModule = require('./modules/userModule')
Users = new userModule(app.router, apiRoutes.user)

app.http.before.push connect.cookieParser('secret here')
app.http.before.push connect.session()
app.http.before.push (req, res, next) ->
  Users.setUser req, res, next
app.http.before.push (req, res, next) ->
  Users.redirect req, res, next

app.start(port)
module.exports = app