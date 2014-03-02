@SharedCtrl = ($scope) ->
  angular.extend $scope,
    selectAll: (objectScope) ->
      for object in unchunk objectScope
        object.checked = true

    unselectAll: (objectScope) ->
      for object in unchunk objectScope
        object.checked = false

SharedCtrl.$inject = ['$scope']
