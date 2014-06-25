DEBUG = process.env.NODE_ENV is 'development'

module.exports = (grunt) ->
  
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    connect:
      server:
        options:
          port: 3000
          hostname: '*'
          base: 'www'
          # keepalive: true

    'gh-pages':
      options:
        base: 'www'
      src: ['**']

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

    jade:
      compile:
        options:
          data:
            DEBUG: DEBUG
        files:
          'www/index.html': ['views/index.jade']

    watch:
      stylus:
        files: ['styles/*.styl']
        tasks: ['stylus']
      browserify:
        files: ['client.coffee']
        tasks: ['browserify']
      jade:
        files: ['views/*.jade']
        tasks: ['jade']
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
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-gh-pages'

  grunt.registerTask 'default', ['browserify', 'stylus', 'jade']
  grunt.registerTask 'server', ['connect', 'watch']
