mocha = require 'mocha'
assert = require 'assert'
coffee = require 'coffee-script'
flatiron = require 'flatiron'
app = flatiron.app
apiRoutes = require '../../lib/json/apiRoutes'
userModule = require '../../lib/modules/userModule'

app.use flatiron.plugins.http

validUser =
  email: 'chris@christopheresplin.com'
  password: 'user'

loginReq =
  body:
    email: validUser.email
    password: validUser.password
  session:
    redirect: '/arbitrary/redirect/route'

Users = new userModule(app.router, apiRoutes.user, true)

suite('Add users', ->
  validMessage = null
  user = null
  setup((done) ->
    Users.createUser
      body: validUser
      headers:
        host: "localhost"
    , (result) ->
      validMessage = result.message
      Users.findUserByEmail(validUser.email, (error, result) ->
        user = result[0]
        done()
      )
  )

  teardown((done) ->
    Users.removeUser user._id, (error, result) ->
      done()
  )

  suite('Add a valid user', ->
    test('Should send confirmation email', ->
      assert.equal validMessage, 'A confirmation email has been sent to ' + validUser.email + '.'
    )

    test('Should return a valid user', ->
      assert.equal(validUser.email, user.email)
    )

    test('Confirmation should fail with bad token', (done) ->
      Users.confirmUser user.email, '123456', (error, result) ->
        assert.equal error.message, 'Confirmation tokens did not match.'
        assert.equal false, result[0].confirmed
        done()
    )

    test('Confirmation should succeed with good token', (done) ->
      Users.confirmUser user.email, user.confirmationGuid, (error, result) ->
        assert.equal true, result[0].confirmed
        done()
    )

    test('Login should succeed with good password', (done) ->
      Users.login loginReq, (message, code) ->
        assert.equal message.user._id.length, user._id.length
        assert.equal code, undefined
        assert.equal message.user.password, null
        assert.equal message.user.salt, null
        assert.equal message.user.confirmationGuid, null
        assert.equal message.user.resetGuid, null
        done()
    )

    test('Login should fail with bad password', (done) ->
      loginReq.body.password = 'jibberjabber'
      Users.login loginReq, (message, code) ->
        assert.equal message.message, 'User not found'
        assert.equal code, 404
        done()
    )


  )
)