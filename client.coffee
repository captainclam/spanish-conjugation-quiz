window._ = require 'underscore'
tenses = require './tenses.coffee'
pronouns =  require './pronouns.coffee'

allTenses = _.clone tenses
allPronouns = _.clone pronouns

retrieve = (k) -> JSON.parse localStorage.getItem k
store = (k, v) -> localStorage.setItem k, JSON.stringify v

window.usingVerbs = retrieve 'usingVerbs' # for filtering
usingTenses = retrieve 'usingTenses'
usingPronouns = retrieve 'usingPronouns'

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
  {
    name: 'strict'
    message: 'Strict accents? (requires áéíóñ instead of aeion)'
    type: 'flag'
    default: retrieve 'strict'
  }
]

translate =  (str) ->
  # todo: non-strict
  verb = _.findWhere verbs, infinitive: str
  if verb
    return verb.translation 
  else
    for verb in verbs
      for arr, pi in verb.conjugations
        if str in arr
          pronoun = allPronouns[pi]
          tense = allTenses[arr.indexOf(str)]
          return  "#{verb.translation} (#{verb.infinitive}, #{pronoun}, #{tense})"

toggleTranslate = ->
  $('.translate.pane').toggle()
  if $('.translate.pane').is(':visible')
    $('.translate.pane input').select()
    return false

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
    $('.prompts').prepend pane

    if prompt.type is 'flag'
      input = $ '<input type="checkbox">'
      input.attr 'name', prompt.name
      label = $('<label>').append(input).append(prompt.message)
      pane.html label
      input.on 'change', -> store prompt.name, input.prop 'checked'
      input.prop 'checked', prompt.default
    else
      pane.text prompt.message
      _.each prompt.choices, (option) ->
        input = $ '<input type="checkbox">'
        input.attr 'name', prompt.name
        label = $('<label>').append(input).append(option)
        pane.append label
        input.prop 'checked', option in prompt.default
        input.val option


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
  $('.quiz .response').focus()

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

  $('.quiz .submit').off 'click'
  $('.quiz .submit').one 'click', ->
    response = $('.response').val()
    asked++

    answer = verb.conjugations?[pi]?[ti]?.trim?()

    if retrieve 'strict'
      right = response is answer
    else
      right = normalise(response) is normalise(answer)

    $('.result').toggleClass 'correct', right
    if right
      correct++
      $('.result').html answer + ' is CORRECT!'
    else
      $('.result').html 'WRONG! Correct Answer: ' + answer

    $('.score').html correct + ' / ' + asked
    $('.quiz .response').val('')
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

  $('.toggle-verbs').click ->
    $('.using-verbs').toggleClass 'active'

  $('.response').keyup (e) ->
    if e.keyCode is 13
      $(this).next('.submit').trigger 'click'

    if e.keyCode is 27
      $(this).closest('.pane').find('.close-pane').click()

  $('.translate .submit').on 'click', ->
    input = $('.translate .response')
    translation = translate input.val()
    $('.translation').text translation or ''
    input.select()

  key '`', toggleTranslate
  $('.toggle-translate').on 'click', toggleTranslate

  $('.close-pane').on 'click', ->
    $(this).closest('.pane').hide()
