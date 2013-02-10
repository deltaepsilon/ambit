
define(['lib/revalidator'], function(revalidator) {
  var User;
  console.log('revalidator', revalidator);
  User = {
    createUser: function(user) {
      if (!user.email) {
        throw new Error('Email missing');
      }
      if (!user.password) {
        throw new Error('password');
      }
    }
  };
  return User;
});
