_ = require 'underscore'
request = require 'request'

jsdom = require 'jsdom'
global.window = jsdom.jsdom().createWindow()
global.document = window.document
global.jQuery = require('jquery').create(window) # WARNING: jQuery for testing is 1.8.3 - different to app
global.$ = global.jQuery

verbs = 'ser,estar,hacer,poder,llevar,decir,llegar,ir,querer,poner,saber,pedir,salir,dar,haber,dejar,seguir,pasar,quedar,pensar'
verbs = verbs.split(',')

count = 0
fetch = (verb) ->
  url = "http://www.spanishdict.com/conjugate/#{verb}"
  request url, (err, data, body) ->
    if err
      console.warn err
    if body
      console.log verb
      dom = $ body
      # console.log arguments...
      rows = dom.find('.table.table-condensed.table-bordered:eq(0) tr')
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
