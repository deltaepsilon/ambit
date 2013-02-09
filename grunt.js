module.exports = function(grunt) {


    grunt.initConfig({
        less: {
            app: {
                options: {
                    // yuicompress: true, //Use for production
                    paths: ['assets/styles/less']
                },
                files: {
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
                files: ['assets/scripts/coffee/*'],
                tasks:'coffee concat'
            }

        }
    });

    grunt.registerTask('server', 'Start Ambit web server', function() {
        var port = 3000;
        grunt.log.writeln('Started web server on port ' + port)
        require('./lib/ambit.coffee').start(port);
    });



    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-coffee');


    grunt.registerTask('default', ['less', 'coffee', 'concat']);
}
