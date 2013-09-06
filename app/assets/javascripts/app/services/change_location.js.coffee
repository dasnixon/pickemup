#angular.module('location', []).factory('changeLocation', ['$scope', '$location', ($scope, $location) ->
  #get: (url, forceReload) ->
    #$scope = $scope or angular.element(document).scope()
    #if forceReload or $scope.$$phase
      #$window.location = url
    #else
      #$location.path(url)
      #$scope.$apply()
#])
