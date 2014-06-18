module.exports = (grunt) ->
  
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    browserify:
      dist:
        files:
          'www/js/client.js': ['client.coffee']
        options:
          transform: ['coffeeify']
          extensions: '.coffee'

    watch:
      # stylus:
      #   files: ['styles/*.styl']
      #   tasks: ['stylus']
      browserify:
        files: ['client.coffee']
        tasks: ['browserify']

  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['browserify']
