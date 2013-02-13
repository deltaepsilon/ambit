angular.module('Ambit').controller 'notificationController', ($scope, $http) ->
  $scope.getNotifications = () ->
    $http.get('/notifications').success((data, status, headers, config) ->
      $scope.type = data.type
      $scope.notification = data.message
    ).error((data, status, headers, config) ->
      console.log 'notifications query failed', arguments
    )