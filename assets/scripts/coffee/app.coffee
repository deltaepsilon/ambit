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
    $routeProvider.otherwise
      redirectTo: '/'
])

angular.module('Ambit').controller 'loginController', ->
  console.log 'inside loginController'