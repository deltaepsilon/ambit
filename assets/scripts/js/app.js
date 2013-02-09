
angular.module('Ambit', ['Ambit.filters', 'Ambit.services', 'Ambit.directives']).config([
  '$routeProvider', function($routeProvider) {
    $routeProvider.when('/', {
      templateUrl: 'assets/templates/partials/front.html'
    });
    $routeProvider.when('/user', {
      templateUrl: 'assets/templates/partials/user.html'
    });
    $routeProvider.when('/login', {
      templateUrl: 'assets/templates/partials/login.html'
    });
    return $routeProvider.otherwise({
      redirectTo: '/'
    });
  }
]);

angular.module('Ambit').controller('loginController', function() {
  return console.log('inside loginController');
});
