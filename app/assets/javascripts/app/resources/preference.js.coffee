preference_app.factory('Preference', ['$resource', ($resource) ->
  $resource '/users/:user_id/:action.json',
    {user_id: '@user_id', action: '@action'},
    'get':    {method:'GET'},
    'update': {method:'PUT'},
    'getPreference': {method: 'GET'}
])
