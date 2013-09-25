userEdit.factory('User', ['$resource', ($resource) ->
  $resource '/users/:id/:action',
    {id: '@id', action: '@action' },
    'get': {method: 'GET'},
    'update': {method: 'PUT'},
    'searchJobs': {method: 'GET'}
])
