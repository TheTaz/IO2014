module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-yuidoc'

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffeelint:
      configFile: 'coffeelint.json'
      app: [
        'Gruntfile.coffee'
        'server.coffee'
        'src/**/*.coffee'
        'spec/**/*.coffee'
        'accept/**/*.coffee'
      ]

    yuidoc:
      all:
        name: 'io-2014-docs'
        description: 'volunteer computing documentation'
        version: '0.2.1'
        options:
          linkNatives: 'true'
          paths: ['./src/']
          outdir: './doc/'
          syntaxtype: 'coffee'
          extension: '.coffee'
