userEdit.factory('Home', ['$resource', ($resource) ->
  $resource '/:action.json',
    {action: '@action' },
    'getMatches': {method: 'GET'}
])

jobListing.factory('Home', ['$resource', ($resource) ->
  $resource '/:action.json',
    {action: '@action' },
    'getMatches': {method: 'GET'}
])
