module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)
  path = require('path')
  pkg = grunt.file.readJSON("package.json")
  DEBUG = false # 添加测试所需代码，发布时应该为false

  grunt.initConfig 
    pkg: pkg
    meta:
      banner: "/**\n" + " * <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today(\"yyyy-mm-dd\") %>\n" + " * <%= pkg.homepage %>\n" + " *\n" + " * Copyright (c) <%= grunt.template.today(\"yyyy\") %> <%= pkg.author %>\n" + " * Licensed <%= pkg.licenses.type %> <<%= pkg.licenses.url %>>\n" + " */\n"

    changelog:
      options:
        dest: "CHANGELOG.md"
        template: "changelog.tpl"

    bump:
      options:
        files: ["package.json", "bower.json"]
        commit: true
        commitMessage: "chore(release): v%VERSION%"
        commitFiles: ["-a"]
        createTag: true
        tagName: "v%VERSION%"
        tagMessage: "Version %VERSION%"
        push: true
        pushTo: "origin"

    clean: 
      all:
        dot: true
        files:
          src: ["bin/*"]

    copy:
      build_app_assets:
        files: [
          src: ["**/*.*", "!**/*.{jade,ls,sass}"]
          dest: "bin/"
          cwd: "src/"
          expand: true
        ]

    concat:
      build_css:
        src: [
          "bin/**/*.css"
          "!bin/<%= pkg.name %>*.css"
          "!bin/vendor/**/*.css"
          "!bin/tests/**/*.css"
          "!bin/**/debug.css"
        ]
        dest: "bin/<%= pkg.name %>-<%= pkg.version %>.css"

    jade:
      options:
        pretty: true
        data: 
          debug: DEBUG
          pkg: pkg

      index:
        expand: true
        cwd: "src"
        src: ["index.jade"]
        dest: "bin"
        ext: ".html"

    sass:
      options:
        includePaths: require('node-bourbon').with('src/common/sass')
      build:
        files: [
          src: ["**/*.sass"]
          dest: "bin/"
          cwd: "src/"
          expand: true
          ext: ".css"
        ]

    livescript:
      options:
        bare: false
      client:
        expand: true
        cwd: "src/"
        src: ["**/*.ls"]
        dest: "bin/"
        ext: ".js"
      index:
        options:
          bare: false
        expand: true
        cwd: "src/"
        src: ["index.ls"]
        dest: "bin/"
        ext: ".js"
      server:
        expand: true
        cwd: "server/"
        src: ["**/*.ls", "!host-config.example.ls"]
        dest: "bin/"
        ext: ".js"

    # bower:
    #   all:
    #     rjsConfig: 'bin/at-plus-page/index.js'
    #     options:
    #       exclude: []
    #       # baseUrl: ' bin/'
    #       transitive: true    

    express:
      dev:
        options:
          server: path.resolve('bin/server.js')
          bases: [path.resolve('bin')]
          livereload: 8001
          # serverreload: true
          port: 8000

    delta:
      options:
        livereload: true

      jade:
        files: ["src/**/*.jade", "tests/**/*.jade"]
        tasks: ["jade"]

      livescriptclient:
        files: ["src/**/*.ls", "!src/at-plus-page/index.ls"]
        tasks: ["newer:livescript:client"]

      livescriptindex:
        files: ["src/at-plus-page/index.ls"]
        tasks: ["livescript:index"]

      livescriptserver:
        files: ["server/**/*.ls"]
        tasks: ["newer:livescript:server", "express-restart"]
        options:
          livereload: false

      sass_src:
        files: ["src/**/*.sass"]
        tasks: [
          "sass:build"
          "concat:build_css"
        ]

      assests:
        files: ["src/assests/**/*"]
        tasks: [
          "newer:copy:build_app_assets"
        ]

      concat_client:
        files: ["bin/**/*.js"]
        tasks: [
          "newer:concat"
        ]

      express:
        files: ["bin/**/*.*", "!bin/server.js", "!bin/data.js"]
        tasks: []
        options:
          livereload: 8001

 
  grunt.renameTask "watch", "delta"

  grunt.registerTask "watch", [
    "build"
    # "karma:unit"
    "express"
    "delta"
  ]
  grunt.registerTask "default", [
    "build"
    # "compile"
  ]
  grunt.registerTask "build", [
    "clean"
    "copy:build_app_assets"
    # "copy:tests"
    "jade"
    "livescript"
    "sass"
    "concat"
    # "copy:chrome_extension"
    # "wiredep"
    # "bower"
  ]
  # grunt.registerTask "compile", [
  #   "sass:compile"
  #   "copy:compile_assets"
  #   "ngmin"
  #   "concat:compile_js"
  #   "uglify"
  #   "index:compile"
  #   "jade:index"
  #   "wiredep:compile"
  # ]
  
  