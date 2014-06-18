window._ = require 'underscore'

tenses = require './tenses.coffee'
pronouns =  require './pronouns.coffee'

window.usingVerbs = JSON.parse localStorage.getItem('usingVerbs') # for filtering
verbs = null

$ ->
  $.ajax({
    dataType: "json",
    url: 'dict.json',
    success: (data) ->
      window.usingVerbs ?= _.pluck(data, 'infinitive').slice(0, 10) # start with just 10
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
  verbPane = $('.using-verbs')
  verbPane.on 'change', 'input', (e) ->
    if $(e.currentTarget).hasClass 'select-all'
      checked = $(e.currentTarget).prop 'checked'
      verbPane.find('input').prop 'checked', checked
    using = _.map $('.using-verbs input:checked'), (el) -> el.value
    window.usingVerbs = using
    localStorage.setItem 'usingVerbs', JSON.stringify using

  for verb in verbs
    input = $ '<input type="checkbox">'
    input.prop 'checked', verb.infinitive in window.usingVerbs
    input.val verb.infinitive
    label = $('<label>').html(verb.infinitive)
    label.prepend input
    verbPane.append label

  for prompt in prompts
    pane = $ '<div class="prompt">'
    pane.append prompt.message
    for option in prompt.choices
      input = $ '<input type="checkbox">'
      input.attr 'name', prompt.name
      input.prop 'checked', option in prompt.default
      input.val option
      label = $('<label>').append(input).append(option)
      pane.append label
    $('.prompts').append pane

  button = $ '<button>Start Quiz</button>'
  button.on 'click', ->
    ts = _.map $('.prompts').find('input[name=tenses]:checked'), (el) -> el.value
    ps = _.map $('.prompts').find('input[name=pronouns]:checked'), (el) -> el.value
    tenses = tenses.map (t) ->
      if ts.indexOf(t) >= 0
        return t
      else
        return null # got to keep order/place
    pronouns = pronouns.map (t) ->
      if ps.indexOf(t) >= 0
        return t
      else
        return null # got to keep order/place
    $('.prompts').hide()
    $('.quiz').show()
    ask()
  $('.show-prompts').click ->
    $('.quiz').hide()
    $('.prompts').show()
  $('.prompts').append button

  $('.response').keyup (e) ->
    # console.log e.keyCode
    if e.keyCode is 13
      $('.submit').trigger 'click'
      # console.log 'ENTER'


asked = 0
correct = 0
used = []
repeated = 0

rand = (arr) ->
  unless arr.length
    return null
  index = _.random(0, arr.length - 1)
  return arr[index]

ask = ->
  $('.response').focus()

  verb = rand _.filter verbs, (v) -> v.infinitive in usingVerbs

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

  # if _.contains used, question
  #   repeated++
  #   if repeated > 10
  #     alert 'run out of questions. please select more verbs'
  #   else
  #     return ask()
  # repeated = 0
  # used.push question

  $('.tense .value').text tense
  $('.verb .value').text verb.infinitive
  $('.pronoun .value').text pronoun
  $('.translation .value').text verb.translation

  $('.translation').toggle verb.translation?.length > 0

  $('.submit').off 'click'
  $('.submit').one 'click', ->
    response = $('.response').val()
    asked++

    $('.result').toggleClass 'correct', response is answer
    if response is answer
      correct++
      $('.result').html 'CORRECT!'
    else
      $('.result').html 'WRONG! Correct Answer: ' + answer

    $('.score').html correct + '/' + asked
    $('.response').val('')
    ask()
