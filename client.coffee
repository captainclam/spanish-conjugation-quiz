window._ = require 'underscore'
tenses = require './tenses.coffee'
pronouns =  require './pronouns.coffee'

window.usingVerbs = JSON.parse localStorage.getItem('usingVerbs') # for filtering

usingTenses = JSON.parse localStorage.getItem('usingTenses')
usingPronouns = JSON.parse localStorage.getItem('usingPronouns')

verbs = null
asked = 0
correct = 0

prompts = [
  {
    name: 'tenses'
    message: 'Which tenses do you want to test?'
    choices: tenses
    default: usingTenses or ['Presente', 'Pretérito', 'Imperfecto']
  }
  {
    name: 'pronouns'
    message: 'Which pronouns do you want to test?'
    choices: pronouns
    default: usingPronouns or _.without pronouns, 'vosotros'
  }
]

toggleQuiz = ->
  $('.prompts').toggle()
  $('.quiz').toggle()

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
    $('.prompts').prepend pane

rand = (arr) ->
  unless arr.length
    return null
  index = _.random(0, arr.length - 1)
  return arr[index]

normalise = (str) ->
  str = str.toLowerCase()
  replaces =
    'á': 'a'
    'é': 'e'
    'í': 'i'
    'ó': 'o'
    'ñ': 'n'
  for k, v of replaces
    regexp = new RegExp k, 'gi'
    str = str.replace regexp, v
  return str

ask = ->
  $('.response').focus()

  verb = rand _.filter verbs, (v) ->
    v.infinitive in usingVerbs

  ti = _.random 0, tenses.length - 1
  pi = _.random 0, pronouns.length - 1
  tense = tenses[ti]
  pronoun = pronouns[pi]
  unless tense? and pronoun?
    return ask() # null tenses/pronouns have been opted out of

  $('.tense .value').text tense
  $('.verb .value').text verb.infinitive
  $('.pronoun .value').text pronoun
  $('.translation').text '(' + verb.translation + ')'

  $('.translation').toggle verb.translation?.length > 0

  $('.submit').off 'click'
  $('.submit').one 'click', ->
    response = $('.response').val()
    asked++

    answer = verb.conjugations?[pi]?[ti]?.trim?()

    right = normalise(response) is normalise(answer)

    $('.result').toggleClass 'correct', right
    if right
      correct++
      $('.result').html 'CORRECT!'
    else
      $('.result').html 'WRONG! Correct Answer: ' + answer

    $('.score').html correct + '/' + asked
    $('.response').val('')
    ask()

$ ->

  $.ajax
    dataType: 'json',
    url: 'dict.json',
    success: (data) ->
      window.usingVerbs ?= _.pluck(data, 'infinitive').slice(0, 10) # start with just 10
      verbs = data
      init()

  $('.start-quiz').on 'click', ->
    ts = _.map $('.prompts').find('input[name=tenses]:checked'), (el) -> el.value
    ps = _.map $('.prompts').find('input[name=pronouns]:checked'), (el) -> el.value
    tenses = tenses.map (t) -> if ts.indexOf(t) >= 0 then t else null
    pronouns = pronouns.map (t) -> if ps.indexOf(t) >= 0 then t else null
    localStorage.setItem 'usingTenses', JSON.stringify tenses
    localStorage.setItem 'usingPronouns', JSON.stringify pronouns
    toggleQuiz()
    ask()

  $('.show-prompts').click toggleQuiz

  $('.response').keyup (e) ->
    if e.keyCode is 13
      $('.submit').trigger 'click'
