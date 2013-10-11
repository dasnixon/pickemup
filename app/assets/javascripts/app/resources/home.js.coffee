userEdit.factory('Home', ['$resource', ($resource) ->
  $resource '/:action',
    {action: '@action' },
    'getMatches': {method: 'GET'}
])

jobListing.factory('Home', ['$resource', ($resource) ->
  $resource '/:action',
    {action: '@action' },
    'getMatches': {method: 'GET'}
])
