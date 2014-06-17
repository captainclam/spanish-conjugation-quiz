_ = require 'underscore'
fs = require 'fs'
request = require 'request'

parser = require './parser'
data = fs.readFileSync './data', 'utf8'
dict = parser.parse data

jsdom = require 'jsdom'
global.window = jsdom.jsdom().createWindow()
global.document = window.document
global.jQuery = require('jquery').create(window) # WARNING: jQuery for testing is 1.8.3 - different to app
global.$ = global.jQuery

verbs = fs.readFileSync './verbs', 'utf8'
verbs = verbs.split('\n')

existing = _.pluck dict, 'infinitive'
verbs = _.difference verbs, existing
verbs = _.without verbs, ''
# return console.log verbs

count = 0
fetch = (verb) ->
  url = "http://www.spanishdict.com/conjugate/#{verb}"
  request url, (err, data, body) ->
    if err
      console.warn err
    dom = $ body
    rows = dom.find('.table.table-condensed.table-bordered:eq(0) tr')
    if body and rows.length
      console.log verb
      # console.log arguments...
      rows.each ->
        if $(this).text().indexOf('Present') >= 0
          return true # continue
        console.log $(this).text().replace(/\n/g, ' ').replace(/[\s]+/g, ' ').trim()
      console.log ''

    # fetch in series
    verb = verbs[++count]
    if verb
      fetch verb

fetch verbs[0]
