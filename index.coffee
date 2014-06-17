_ = require 'underscore'
fs = require 'fs'

data = fs.readFileSync './data.txt', 'utf8'

questions = data.split '\n\n'
questions = questions.map (line) ->
  lines = line.split '\n'
  return {
    title: lines[0]
    answers: lines.slice(2)
  }

# console.log questions
# console.log '------------------------'

readline = require 'readline'
rl = readline.createInterface
  input: process.stdin
  output: process.stdout

asked = 0
correct = 0

ask = ->
  index = _.random 0, questions.length - 1
  question = questions[index]
  # console.log question
  # return
  
  i2 = _.random 0, question.answers.length - 1
  answer = question.answers[i2]
  [q, a] = answer.split ':'

  grr = question.title + ': ' + q + ' '

  rl.question grr, (r) ->
    asked++
    if r is 'clear'
      process.stdout.write '\u001B[2J\u001B[0;0f'
    else if r is 'score'
      console.log correct + '/' + asked
    else if r is 'skip'
      console.log 'skipped'
    else if r in ['exit', 'quit']
      return rl.close()
    else if r is a.trim()
      correct++
      console.log 'YOU RIGHT!\n'
    else
      console.log 'WRONG!!!', a, '\n'
    ask()
ask()
