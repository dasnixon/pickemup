angular.module('ck-editor', [])
  .directive "ckEditor", ->
    require: "?ngModel"
    link: (scope, elm, attr, ngModel) ->
      ck = CKEDITOR.replace(elm[0])
      return  unless ngModel
      ck.on "pasteState", ->
        scope.$apply ->
          ngModel.$setViewValue ck.getData()

      ngModel.$render = (value) ->
        ck.setData ngModel.$viewValue
