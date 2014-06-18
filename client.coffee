_ = require 'underscore'

tenses = require './tenses.coffee'
pronouns =  require './pronouns.coffee'

verbs = null

$ ->
  $.ajax({
    dataType: "json",
    url: 'dict.json',
    success: (data) ->
      verbs = data
      init()
  });

prompts = [
  {
    name: 'tenses'
    message: 'Which tenses do you want to test?'
    type: 'checkbox'
    choices: tenses
    default: ['Presente', 'Pretérito', 'Imperfecto']
  }
  {
    name: 'pronouns'
    message: 'Which pronouns do you want to test?'
    type: 'checkbox'
    choices: pronouns
    default: _.without pronouns, 'vosotros'
  }
]

init = ->
  pane = $ '.prompts'
  for prompt in prompts
    pane.append prompt.message
    for option in prompt.choices
      input = $ '<input type="checkbox">'
      input.attr 'name', prompt.name
      input.prop 'checked', option in prompt.default
      input.val option
      label = $('<label>').append(input).append(option)
      pane.append label
  button = $ '<button>Start Quiz</button>'
  button.one 'click', ->
    tenses = _.map pane.find('input[name=tenses]:checked'), (el) -> el.value
    pronouns = _.map pane.find('input[name=pronouns]:checked'), (el) -> el.value
    pane.remove()
    $('.quiz').show()
    ask()
  pane.append button

answerprompts = (answers) ->

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

  $('.tense .value').text tense
  $('.verb .value').text verb.infinitive
  $('.pronoun .value').text pronoun

  $('.submit').one 'click', ->
    response = $('.response').val()
    asked++
    switch response
      when answer
        correct++
        $('.result').html 'CORRECT!'
      else
        $('.result').html 'WRONG! Correct Answer: ' + answer

    $('.score').html correct + '/' + asked
    $('.response').val('')
    ask()