angular.module('Ambit.directives', []).directive('appVersion',
  'version'
  (version) ->
    (scope, elm, attr) ->
      elm.text version)