angular.module('attributeArrayLimit', []).filter 'attributeArrayLimit', ->
  (scope, maxLength) ->
    if scope?
      maxLength ?= 50
      for length in [12..0].slice(0)
        shortenedArray = scope[0..length].join(', ')
        return shortenedArray if shortenedArray.length <= maxLength
    else
      ''
