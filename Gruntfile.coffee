module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    clean:
      bin: './bin/'
      coffee: './bin/**/*.coffee'
      publicScripts: './bin/public_scripts/'

    copy:
      main:
        expand: true
        cwd: './src/'
        src: '**'
        dest: './bin/'
        filter: 'isFile'

      publicScripts:
        expand: true
        cwd: './bin/public_scripts/'
        src: '**'
        dest: './public/scripts'
        filter: 'isFile'

    coffee:
      glob_to_multiple:
        expand: true
        cwd: './bin/'
        src: './**/*.coffee'
        dest: './bin/'
        ext: '.js'

    jshint:
      options:
        jshintrc: true

      all: [
        './src/**/*.js'
        './spec/**/*.js'
        './acceptance_test/**/*.js'
      ]

    coffee_jshint:
      options:
        jshintrc: true,
        jshintOptions: [
          'evil'
          "camelcase"
          "trailing"
        ]
        globals: [
          'console'
          'require'
          'module'
          'jasmine'
          'it'
          'expect'
        ]

      source: './src/**/*.coffee'
      specs: './spec/**/*.coffee'
      accceptance_tests: './acceptance_test/**/*.coffee'

    yuidoc:
      all:
        name: 'io-2014-docs'
        description: 'volunteer computing documentation'
        version: '0.2.1'
        options:
          linkNatives: 'true'
          paths: ['./src/']
          outdir: './docs/'
          syntaxtype: 'coffee'
          extension: '.coffee'


  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-coffee-jshint'
  grunt.loadNpmTasks 'grunt-contrib-yuidoc'

  grunt.registerTask 'default', [
    #'coffee_jshint'
    'clean:bin'
    'copy:main'
    'coffee'
    'clean:coffee'
    'copy:publicScripts'
    'clean:publicScripts'
    'yuidoc'
  ]