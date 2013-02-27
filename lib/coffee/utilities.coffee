fs = require 'fs'
consolidate = require 'consolidate'

class utilities
  constructor: (options) ->
    @options = options
  getTemplate: (fileName) ->
    path = @options.templateDir || ''
    path += '/' + fileName + '.html'
    return fs.readFileSync path, 'utf8'
  renderTemplate: (fileName, directive, map) ->
    html = @getTemplate(fileName)
    console.log 'directive', directive
#    return consolidate.swig.bind html, directive, map

module.exports = utilities