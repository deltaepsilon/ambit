fs = require 'fs'

class utilities
  constructor: (options) ->
    @options = options
  getTemplate: (fileName) ->
    path = @options.templateDir || ''
    path += '/' + fileName + '.html'
    return fs.readFileSync path, 'utf8'

module.exports = utilities