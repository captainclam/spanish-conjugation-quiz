module.exports =
  parse: (data) ->
    data = data.split '\n\n'
    verbs = data.map (line) ->
      lines = line.split '\n'
      return {
        infinitive: lines[0]
        conjugations: lines.slice(1).map (line) ->
          line.split(/[\s]+/g).slice(1)
      }
