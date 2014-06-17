# parse spanishdict copy pasta

_ = require 'underscore'
fs = require 'fs'

data = fs.readFileSync './spanishdict.txt', 'utf8'

tenses = ['Presente', 'Pretérito', 'Imperfecto', 'Condicional', 'Futuro']
prefixes = ['yo', 'tú', 'él/ella/usted', 'nosotros', 'vosotros', 'ellos/ellas/ustedes']

data = data.split '\n\n'
verbs = data.map (line) ->
  lines = line.split '\n'
  return {
    infinitive: lines[0]
    conjugations: lines.slice(1).map (line) ->
      line.split(/[\s]+/g).slice(1)
  }

for verb in verbs
  for tense, i in tenses
    console.log verb.infinitive, tense, ':'
    for prefix, j in prefixes
      console.log prefix, verb.conjugations[i][j]
    console.log ''
  console.log '------------------------'
