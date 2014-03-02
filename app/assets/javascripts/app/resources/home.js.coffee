pickemup.factory('Home', ['$resource', ($resource) ->
  $resource '/:action.json',
    { action: '@action' }
])
