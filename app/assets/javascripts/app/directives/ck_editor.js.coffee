angular.module('ck-editor', []).directive "ckEditor", ->
  require: "?ngModel"
  link: (scope, elm, attr, ngModel) ->
    ck = CKEDITOR.replace(elm[0],
      toolbar_Full: [
        name: "document"
        items: []
      ,
        name: "clipboard"
        items: ["Cut", "Copy", "Paste", "PasteText", "PasteFromWord", "-", "Undo", "Redo"]
      ,
        name: "editing"
        items: ["Find", "Replace", "-", "SpellChecker", "Scayt"]
      ,
        name: "forms"
        items: []
      ,
        name: "basicstyles"
        items: ["Bold", "Italic", "Underline", "Strike", "Subscript", "Superscript"]
      ,
        name: "paragraph"
        items: ["NumberedList", "BulletedList", "-", "JustifyLeft", "JustifyCenter", "JustifyRight", "JustifyBlock"]
      ,
        name: "links"
        items: []
      ,
        name: "insert"
        items: ["SpecialChar"]
      , "/",
        name: "styles"
        items: ["Styles", "Format", "Font", "FontSize"]
      ,
        name: "colors"
        items: []
      ,
        name: "tools"
        items: ["Maximize"]
      ]
      height: "290px"
      width: "99%"
    )
    return  unless ngModel

    ck.on "instanceReady", ->
      ck.setData ngModel.$viewValue

    ck.on "pasteState", ->
      scope.$apply ->
        ngModel.$setViewValue ck.getData()

    ngModel.$render = (value) ->
      ck.setData ngModel.$viewValue
