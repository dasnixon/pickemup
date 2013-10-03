angular.module("igTruncate", []).filter "truncate", ->
  (text, length, end) ->
    if text?
      length ?= 10
      end ?= "..."
      if text.length <= length or text.length - end.length <= length
        text
      else
        String(text).substring(0, length - end.length) + end
