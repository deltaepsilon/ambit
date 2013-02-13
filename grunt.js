module.exports = function(grunt) {


    grunt.initConfig({
        less: {
            app: {
                options: {
                    // yuicompress: true, //Use for production
                    paths: ['assets/styles/less']
                },
                files: {
                    'assets/styles/css/objects.css': 'assets/styles/less/objects.less',
                    'assets/styles/css/core.css': 'assets/styles/less/core.less'
                }
            }
        },
        coffee: {
            app: {
                src: ['assets/scripts/coffee/*.coffee'],
                dest: 'assets/scripts/js'
            },
            filters: {
                src: ['assets/scripts/coffee/filters/*.coffee'],
                dest: 'assets/scripts/js/filters'
            },
            services: {
                src: ['assets/scripts/coffee/services/*.coffee'],
                dest: 'assets/scripts/js/services'
            },
            directives: {
                src: ['assets/scripts/coffee/directives/*.coffee'],
                dest: 'assets/scripts/js/directives'
            },
            modules: {
                src: ['assets/scripts/coffee/modules/*.coffee'],
                dest: 'assets/scripts/js/modules'
            },
            controllers: {
                src: ['assets/scripts/coffee/controllers/*.coffee'],
                dest: 'assets/scripts/js/controllers'
            },
            test: {
                src: ['test/coffee/*.coffee'],
                dest: 'test/js'
            }
        },
        concat: {
            css: {
                src: ['assets/styles/css/*.css'],
                dest: 'assets/styles/style.css'
            },
            filters: {
                src: ['assets/scripts/js/filters/*.js'],
                dest: 'assets/scripts/js/filters.js'
            },
            services: {
                src: ['assets/scripts/js/services/*.js'],
                dest: 'assets/scripts/js/services.js'
            },
            directives: {
                src: ['assets/scripts/js/directives/*.js'],
                dest: 'assets/scripts/js/directives.js'
            },
            app: {
                src: ['assets/scripts/js/modules/*.js', 'assets/scripts/js/controllers/*.js'],
                dest: 'assets/scripts/js/app.js'
            }
        },
        mochaTest: {
          normal: ['test/js/*.js']
        },
        mochaTestConfig: {
            normal: {
                options: {
                    ui: 'tdd'
                }
            }
        },
        watch: {
//            server: {
//                files: ['./lib/*'],
//                tasks: 'server'
//            },
            less: {
                files: ['assets/styles/less/*'],
                tasks:'less concat'
            },
            js: {
                files: ['assets/scripts/coffee/*', 'assets/scripts/coffee/*/*'],
                tasks:'coffee concat'
            },
            mocha: {
                files: ['test/coffee/*'],
                tasks: 'coffee:test mochaTest'
            }
        }
    });

    grunt.registerTask('server', 'Start Ambit web server', function() {
        var port = 3000;
        grunt.log.writeln('Started web server on port ' + port)
        require('./lib/ambit.coffee').start(port);
    });



    grunt.loadNpmTasks('grunt-mocha-test')
    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-coffee');


    grunt.registerTask('default', ['less', 'coffee', 'concat', 'mochaTest']);
}
