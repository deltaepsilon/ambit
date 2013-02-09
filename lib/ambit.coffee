port = process.argv[2] || 3000;
flatiron = require 'flatiron'
plates = require 'plates'
app = flatiron.app
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


app.start(port)
module.exports = app
