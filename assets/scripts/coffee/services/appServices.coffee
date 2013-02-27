angular.module 'Ambit.services', [], ($provide) ->
  $provide.provider 'apiRoutes', () ->
    this.$get = () ->
      result =
        test: 'me'
      return result