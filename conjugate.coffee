_ = require 'underscore'
clc = require 'cli-color'
fs = require 'fs'

parser = require './parser'

tenses = require './tenses'
pronouns =  require './pronouns'

data = fs.readFileSync './data', 'utf8'
verbs = parser.parse data

verb = _.findWhere verbs, infinitive: process.argv[2]

if verb
  for tense, ti in tenses
    for pronoun, pi in pronouns
       answer = verb.conjugations?[pi]?[ti]?.trim?()
       console.log [tense, pronoun, answer].join ' '
