DEBUG = process.env.NODE_ENV is 'development'

module.exports = (grunt) ->
  
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    stylus:
      compile:
        options:
          compress: !DEBUG
        files:
          'www/css/main.css': 'styles/main.styl'

    browserify:
      dist:
        files:
          'www/js/client.js': ['client.coffee']
        options:
          transform: ['coffeeify']
          extensions: '.coffee'

    watch:
      stylus:
        files: ['styles/*.styl']
        tasks: ['stylus']
      browserify:
        files: ['client.coffee']
        tasks: ['browserify']
      livereload:
        options:
          livereload: true
        files: [
          'www/css/main.css'
          'www/index.html'
          'www/js/client.js'
        ]

  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['browserify']
