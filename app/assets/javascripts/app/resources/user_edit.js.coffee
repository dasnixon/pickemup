userEdit.factory('User', ['$resource', ($resource) ->
  $resource '/users/:id/:action',
    {id: '@id'},
    'get': {method: 'GET'},
    'update': {method: 'PUT'}
])
