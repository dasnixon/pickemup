angular.module('ck-editor', []).directive('ckEditor', ->
  loaded = false
  calledEarly = false
  {
    require: '?ngModel',
    compile: (element, attributes, transclude) ->
      local = @
      loadIt = ->
        calledEarly = true

      element.ready ->
        loadIt()
      post: ($scope, element, attributes, controller) ->
        return local.link $scope, element, attributes, controller if calledEarly

        loadIt = (($scope, element, attributes, controller) ->
          return ->
            local.link $scope, element, attributes, controller
        )($scope, element, attributes, controller)
    link: ($scope, elm, attr, ngModel) ->
      return unless ngModel

      if (calledEarly and not loaded)
        return loaded = true
      loaded = false

      ck = CKEDITOR.replace(elm[0])

      ck.on('pasteState', ->
        $scope.$apply( ->
          ngModel.$setViewValue(ck.getData())
        )
      )

      ngModel.$render = (value) ->
        ck.setData(ngModel.$viewValue)
  }
)
