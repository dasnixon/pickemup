@preference_app = angular.module('Preferences', ['ngResource', 'ui.compat'])
@skill_app = angular.module('Skills', ['ngResource', 'ui.compat'])

@chunk = (a,s)->
  if a
    if a.length == 0
      []
    else
      ( a[i..i+s-1] for i in [0..a.length - 1 ] by s)

#Convert string into a money format with commas 60000 -> 60,000
@addCommas = (nStr) ->
  nStr += ""
  x = nStr.split(".")
  x1 = x[0]
  x2 = (if x.length > 1 then "." + x[1] else "")
  rgx = /(\d+)(\d{3})/
  x1 = x1.replace(rgx, "$1" + "," + "$2")  while rgx.test(x1)
  x1 + x2
