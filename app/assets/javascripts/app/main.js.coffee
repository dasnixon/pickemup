@app = angular.module('Pickemup', ['ngResource', 'ui.compat'])

@chunk = (a,s)->
  if a
    if a.length == 0
      []
    else
      ( a[i..i+s-1] for i in [0..a.length - 1 ] by s)
