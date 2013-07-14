app.factory 'Preference', ($resource) ->
  $resource '/users/:user_id/:action/',
    {user_id: '@user_id', action: '@action'},
    'get':    {method:'GET'},
    'update': {method:'PUT'},
    'getPreference': {method: 'GET'}
