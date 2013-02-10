class UserAPI
  constructor: (router, path) ->
    @router = router
    @path = path
    @register()

  register: ->
    @router.post @path + '/create', ->
      console.log 'creating user', this.req, this.res

UserModel =
  createUser: (user) ->
    console.log 'model create user', user

exports.api = UserAPI
exports.model = UserModel