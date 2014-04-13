module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    clean: {
      bin: {
        src: 'bin'
      },
      coffee: {
        src: 'bin/*.coffee'
      }
    },
    copy: {
      main: {
        expand: true,
        cwd: 'src/',
        src: '**',
        dest: 'bin/',
        filter: 'isFile'
      }
    },
    coffee: {
      glob_to_multiple: {
        expand: true,
        cwd: 'bin/',
        src: ['*.coffee'],
        dest: 'bin/',
        ext: '.js'
      }
    },
    jshint: {
      options: {
        jshintrc: true
      },
      all: ['src/**/*.js', 'spec/**/*.js']
    },
    coffee_jshint: {
      options: {},
      source: {
        src: 'src/**/*.coffee'
      },
      specs: {
        src: 'spec/**/*.coffee'
      }
    },
    yuidoc: {
      all: {
        name: 'io-2014-docs',
        description: 'volunteer computing documentation',
        version: '0.2.1',
        options: {
          linkNatives: 'true',
          paths: ['./src/'],
          outdir: './docs/',
          syntaxtype: 'coffee',
          extension: '.coffee'
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-coffee-jshint');
  grunt.loadNpmTasks('grunt-contrib-yuidoc');

  grunt.registerTask('default', ['jshint', 'clean:bin', 'copy', 'coffee', 'clean:coffee', 'yuidoc']);

};