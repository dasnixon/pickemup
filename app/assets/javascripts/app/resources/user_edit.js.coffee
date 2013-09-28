userEdit.factory('User', ['$resource', ($resource) ->
  $resource '/users/:id/:action',
    {id: '@id', action: '@action' },
    'searchJobs': {method: 'GET'},
    'get': {method: 'GET'},
    'update': {method: 'PUT'}
])
