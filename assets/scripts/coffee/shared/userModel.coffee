define(['lib/revalidator'], (revalidator) ->
  console.log 'revalidator', revalidator

  User =
    createUser: (user) ->
      if !user.email
        throw new Error('Email missing');
      if !user.password
        throw new Error('password');

  return User
);

