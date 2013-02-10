
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
    $routeProvider.when('/register', {
      templateUrl: 'assets/templates/partials/register.html'
    });
    return $routeProvider.otherwise({
      redirectTo: '/'
    });
  }
]);

angular.module('Ambit').controller('userController', function($scope) {
  $scope.logIn = function(user) {
    return console.log('logging in user', $scope.user);
  };
  return $scope.register = function() {
    return require(['shared/userModel'], function(userModel) {
      var user;
      user = userModel.createUser($scope.user);
      return console.log('registering user', user);
    });
  };
});
