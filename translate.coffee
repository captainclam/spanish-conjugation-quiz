_ = require 'underscore'
fs = require 'fs'
request = require 'request'

dict = require './www/dict.json'

jsdom = require 'jsdom'
global.window = jsdom.jsdom().createWindow()
global.document = window.document
global.jQuery = require('jquery').create(window) # WARNING: jQuery for testing is 1.8.3 - different to app
global.$ = global.jQuery

untranslated = _.where dict, translation: ''
verbs = _.pluck untranslated, 'infinitive'

count = 0
fetch = (verb) ->
  url = "http://www.spanishdict.com/translate/#{verb}"
  request url, (err, data, body) ->
    if err
      console.warn err
    dom = $ body
    heading = dom.find('h2.quick_def')
    if body and heading.length
      translation = heading.text().split(';')[0]
      entry = _.findWhere dict, infinitive: verb
      entry.translation = translation
      fs.writeFileSync './www/dict.json', JSON.stringify(dict)
      console.log verb, translation

    # fetch in series
    verb = verbs[++count]
    if verb
      fetch verb

fetch verbs[0]
