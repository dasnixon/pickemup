pickemup.factory('Auth', ['$http', '$timeout', '$q', ($http, $timeout, $q) ->
  loggedIn: ->
    deferred = $q.defer()
    $http.get('/api/auth/logged_in.json').then (response) ->
      deferred.resolve response
      return

    deferred.promise
])
