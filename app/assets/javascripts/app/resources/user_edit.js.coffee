userEdit.factory('User', ['$resource', ($resource) ->
  $resource '/users/:id/:action.json',
    {id: '@id', action: '@action' },
    'get': {method: 'GET'},
    'update': {method: 'PUT'}
])
