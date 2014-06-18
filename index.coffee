_ = require 'underscore'
clc = require 'cli-color'
fs = require 'fs'
inquirer = require 'inquirer'

parser = require './parser'

tenses = require './tenses'
pronouns =  require './pronouns'

data = fs.readFileSync './data', 'utf8'
verbs = parser.parse data

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
    message: 'Which pronouns do you want to test?'
    type: 'checkbox'
    choices: pronouns
    default: _.without pronouns, 'vosotros'
  }
], (answers) ->
  # console.log answers

  tenses = tenses.map (t) ->
    if answers.a.indexOf(t) >= 0
      return t
    else
      return null # got to keep order/place

  pronouns = pronouns.map (t) ->
    if answers.b.indexOf(t) >= 0
      return t
    else
      return null # got to keep order/place

  # console.log tenses
  # console.log pronouns

  readline = require 'readline'
  rl = readline.createInterface
    input: process.stdin
    output: process.stdout  

  # process.stdout.write '\u001B[2J\u001B[0;0f'

  console.log clc.magentaBright '\nHola amigo! Answer the questions as you\'re prompted, type exit to exit.\n'

  ask()

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
  pi = _.random 0, pronouns.length - 1

  tense = tenses[ti]
  pronoun = pronouns[pi]

  # null tenses/pronouns have been opted out of
  unless tense? and pronoun
    return ask()

  answer = verb.conjugations?[pi]?[ti]?.trim?()

  # return console.log tense, verb.infinitive, ':', pronoun, answer

  question = [tense, verb.infinitive, pronoun, ''].join ' : '

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
