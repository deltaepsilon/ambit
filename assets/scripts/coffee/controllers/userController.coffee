angular.module('Ambit').controller 'userController', ($scope, $http) ->
  $scope.logIn = (user) ->
    $http.post('api/user/login', $scope.user).success((data, status, headers, config) ->
      console.log 'login success', arguments
    ).error((data, status, headers, config) ->
      console.log 'login error', arguments
    )

  $scope.register = () ->
    $http.post('api/user/create', $scope.user).success((data, status, headers, config) ->
      $scope.notification = data.message
      $scope.success = true
    ).error((data, status, headers, config) ->
      $scope.notification = data.message
      $scope.error = true
    )