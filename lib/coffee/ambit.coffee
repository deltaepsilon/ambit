port = process.argv[2] || 3000;
express = require 'express'
consolidate = require 'consolidate'
app = express()
redisStore = require('connect-redis')(express)
parameters = require '../json/parameters'

# RequireJS for the server
requirejs = require 'requirejs'
requirejs.config
  nodeRequire: require
  baseUrl: '../assets/scripts/js/'

#  Utility functions
utilities = require './utilities'
utilities = new utilities
  "templateDir": "./assets/templates"


# Middleware
app.use '/assets', express.directory('assets')
app.use '/assets', express.static(__dirname + '/../../assets')
app.use express.cookieParser()
app.use express.session(
  secret: 'sauce'
  store: new redisStore
)


# Modules
apiRoutes = require '../json/apiRoutes'
userModule = require('./../modules/js/userModule')
Users = new userModule(app, apiRoutes.user)

# Module-dependent middleware
app.use (req, res, next) ->
  Users.redirect req, res, next



# Top-level API
app.get '/', (req, res) ->
  headers =
    'Content-Type': 'text/html'
  if req.session && req.session.notification
    headers['x-notification'] = JSON.stringify req.session.notification
  res.writeHead 200, headers
  res.end utilities.getTemplate 'index'

app.get '/notifications', (req, res) ->
  notification = {}
  if req.session && req.session.notification
    notification = req.session.notification
    req.session.notification = null
  res.writeHead 200,
    'Content-Type': 'text/plain'
  res.end JSON.stringify notification

app.listen(port)
module.exports = app