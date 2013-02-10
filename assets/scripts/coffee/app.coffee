angular.module('Ambit', [
  'Ambit.filters'
  'Ambit.services'
  'Ambit.directives'
]).config([
  '$routeProvider', ($routeProvider) ->
    $routeProvider.when '/',
      templateUrl: 'assets/templates/partials/front.html'
    $routeProvider.when '/user',
      templateUrl: 'assets/templates/partials/user.html'
    $routeProvider.when '/login',
      templateUrl: 'assets/templates/partials/login.html'
    $routeProvider.when '/register',
      templateUrl: 'assets/templates/partials/register.html'
    $routeProvider.otherwise
      redirectTo: '/'
])

angular.module('Ambit').controller 'userController', ($scope) ->
  $scope.logIn = (user) ->
    console.log 'logging in user', $scope.user

  $scope.register = () ->
    require(['shared/userModel'], (userModel) ->
      user = userModel.createUser $scope.user

      console.log 'registering user', user
    );

