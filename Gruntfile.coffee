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

  grunt.loadNpmTasks 'grunt-browserify'  

  grunt.registerTask 'default', ['browserify']
