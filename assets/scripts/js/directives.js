
angular.module('Ambit.directives', []).directive('appVersion', 'version', function(version) {
  return function(scope, elm, attr) {
    return elm.text(version);
  };
});
