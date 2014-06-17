_ = require 'underscore'
clc = require 'cli-color'
fs = require 'fs'
inquirer = require 'inquirer'

tenses = ['Presente', 'Pretérito', 'Imperfecto', 'Condicional', 'Futuro']
prefixes = ['yo', 'tú', 'él/ella/usted', 'nosotros', 'vosotros', 'ellos/ellas/ustedes']

rl = null

inquirer.prompt [
  {
    name: 'a'
    message: 'Which tenses do you want to test?'
    type: 'checkbox'
    choices: tenses
    default: ['Presente', 'Pretérito', 'Imperfecto']
  }
  {
    name: 'b'
    message: 'Which prefixes do you want to test?'
    type: 'checkbox'
    choices: prefixes
    default: _.without prefixes, 'vosotros'
  }
], (answers) ->
  # console.log answers

  tenses = tenses.map (t) ->
    if answers.a.indexOf(t) >= 0
      return t
    else
      return null # got to keep order/place

  prefixes = prefixes.map (t) ->
    if answers.b.indexOf(t) >= 0
      return t
    else
      return null # got to keep order/place

  # console.log tenses
  # console.log prefixes

  readline = require 'readline'
  rl = readline.createInterface
    input: process.stdin
    output: process.stdout  

  # process.stdout.write '\u001B[2J\u001B[0;0f'

  console.log clc.magentaBright '\nHola amigo! Answer the questions as you\'re prompted, type exit to exit.\n'

  ask()

data = fs.readFileSync './data', 'utf8'
data = data.split '\n\n'
verbs = data.map (line) ->
  lines = line.split '\n'
  return {
    infinitive: lines[0]
    conjugations: lines.slice(1).map (line) ->
      line.split(/[\s]+/g).slice(1)
  }

asked = 0
correct = 0
used = []

rand = (arr) ->
  unless arr.length
    return null
  index = _.random(0, arr.length - 1)
  return arr[index]

ask = ->
  verb = rand verbs

  ti = _.random 0, tenses.length - 1
  pi = _.random 0, prefixes.length - 1

  tense = tenses[ti]
  prefix = prefixes[pi]

  # null tenses/prefixes have been opted out of
  unless tense? and prefix
    return ask()

  answer = verb.conjugations?[pi]?[ti]?.trim?()

  # return console.log tense, verb.infinitive, ':', prefix, answer

  question = [tense, verb.infinitive, prefix, ''].join ' : '

  # todo: once all have been asked, this is going to loop forever
  if _.contains used, question
    return ask()
  used.push question

  rl.question question, (response) ->
    asked++
    switch response
      when 'skip'
        console.log 'skipped'
        ask()
      when 'exit', 'quit'
        console.log clc.magentaBright '\n¡Adiós!\n'
        return rl.close()
      when answer
        correct++
        console.log clc.green 'CORRECT!'
        console.log correct + '/' + asked
        console.log ''
        ask()
      else
        console.log clc.red 'WRONG!'
        console.log 'Correct Answer:', answer
        console.log correct + '/' + asked
        console.log ''
        ask()
