angular.module('Ambit').controller 'userController', ['$rootScope', '$scope', '$http', 'apiRoutes', ($rootScope, $scope, $http, apiRoutes) ->
  $scope.getApi = (callback) ->
    if $scope.api
      callback $scope.api
    else
      $http.get('api/user').success((data, status, headers, config) ->
        $scope.api = data
        callback $scope.api
      ).error((data, status, headers, config) ->
        console.log 'error retrieving user api'
      )

  $scope.logIn = (user) ->
    $http.post('api/user/login', $scope.user).success((data, status, headers, config) ->
      $scope.user = data.user;
      $scope.user.loggedIn = true
      location.hash = '/account'
      console.warn 'Find a way to force the navs to re-evaluate their ng-show and ng-hide directives'
    ).error((data, status, headers, config) ->
      $scope.user =
        loggedIn: false
    )

  $scope.register = () ->
    $http.post('api/user/create', $scope.user).success((data, status, headers, config) ->
      $scope.notification = data.message
      $scope.success = true
    ).error((data, status, headers, config) ->
      $scope.notification = data.message
      $scope.error = true
    )

  $scope.save = () ->
    $http.post('api/user/update', $scope.user).success((data, status, headers, config) ->
      $scope.notification = data.message
      $scope.success = true
    ).error((data, status, headers, config) ->
      $scope.notification = data.message
      $scope.error = true
    )

  $scope.getUser = () ->
    $scope.getApi (api) ->
      $http.get(api.base + api.get).success((data, status, headers, config) ->
        if data.error
          $scope.user =
            loggedIn: false
        else
          $scope.user = data
          $scope.user.loggedIn = true
      ).error((data, status, headers, config) ->
        console.log 'User not logged in'
      )

  $scope.logOut = () ->
    $scope.getApi (api) ->
      $http.post(api.base + api.logOut).success(() ->
        $scope.user =
          loggedIn: false
      ).error(() ->
        console.log 'error logging out'
      )
]