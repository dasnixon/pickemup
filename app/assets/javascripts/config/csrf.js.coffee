angular.module('csrf', []).config(['$httpProvider', ($httpProvider) ->
  authToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
])
