port = process.argv[2] || 3000;
flatiron = require 'flatiron'
plates = require 'plates'
app = flatiron.app

# RequireJS for the server
requirejs = require 'requirejs'
requirejs.config
  nodeRequire: require
  baseUrl: '../assets/scripts/js/'

#  Utility functions
utilities = require './utilities'
utilities = new utilities
  "templateDir": "./assets/templates"

app.use flatiron.plugins.http
app.use flatiron.plugins.static,
  dir: './assets'
  index: true
  dot: true
  url: '/assets'


app.router.get '/', ->
  this.res.writeHead 200,
    'Content-Type': 'text/html'
  this.res.end utilities.getTemplate 'index'

# Register Modules


apiRoutes = requirejs '../assets/scripts/js/json/apiRoutes'
userModule = require './modules/userModule'
new userModule.api(app.router, apiRoutes.user.base)

app.start(port)
module.exports = app
