_ = require 'underscore'
clc = require 'cli-color'
fs = require 'fs'

tenses = ['Presente'] #, 'Pretérito', 'Imperfecto'] #, 'Condicional', 'Futuro']
prefixes = ['yo', 'tú', 'él/ella/usted', 'nosotros', 'vosotros', 'ellos/ellas/ustedes']

data = fs.readFileSync './spanishdict.txt', 'utf8'
data = data.split '\n\n'
verbs = data.map (line) ->
  lines = line.split '\n'
  return {
    infinitive: lines[0]
    conjugations: lines.slice(1).map (line) ->
      line.split(/[\s]+/g).slice(1)
  }

readline = require 'readline'
rl = readline.createInterface
  input: process.stdin
  output: process.stdout

asked = 0
correct = 0

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

  # temp hack porque no sé "vosotros"
  if prefix is 'vosotros'
    return ask()

  answer = verb.conjugations?[pi]?[ti]?.trim?()

  # return console.log tense, verb.infinitive, ':', prefix, answer

  question = [tense, verb.infinitive, prefix, ''].join ' : '

  rl.question question, (response) ->
    asked++
    switch response
      when 'clear'
        process.stdout.write '\u001B[2J\u001B[0;0f'
      when 'score'
        console.log correct + '/' + asked
      when 'skip'
        console.log 'skipped'
      when 'exit', 'quit'
        return rl.close()
      when answer
        correct++
        console.log clc.green 'CORRECT!'
        console.log correct + '/' + asked
        console.log ''
      else
        console.log clc.red 'WRONG!'
        console.log 'Correct Answer:', answer
        console.log correct + '/' + asked
        console.log ''
    ask()

process.stdout.write '\u001B[2J\u001B[0;0f'
ask()
