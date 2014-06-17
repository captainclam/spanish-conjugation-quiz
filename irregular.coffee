for verb in verbs
  for tense, ti in tenses
    for prefix, pi in prefixes
      answer = verb.conjugations?[pi]?[ti]?.trim?()
      suffix = verb.infinitive.substr(-2)
      irregular = true
      switch tense
        when 'Presente'
          switch prefix
            when 'yo'
              switch suffix
                when 'ar'
                  regular = answer.substr(0, answer.length-2) + 'o'
                  irregular = answer isnt regular
                when 'er', 'ir'
                  regular = answer.substr(0, answer.length-2) + 'o'
                  irregular = answer isnt regular
            when 'nosotros'
              switch suffix
                when 'ar', 'er', 'ir'
                  regular = answer.substr(0, answer.length-1) + 'mos'
                  irregular = answer isnt regular
      color = if irregular then 'red' else 'green'
      console.log clc[color] [tense, verb.infinitive, prefix, answer].join ' : '
