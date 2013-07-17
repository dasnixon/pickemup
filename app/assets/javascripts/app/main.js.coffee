@preference_app = angular.module('Preferences', ['ngResource', 'ui.compat'])
@skill_app = angular.module('Skills', ['ngResource'])

@chunk = (a,s)->
  if a
    if a.length == 0
      []
    else
      ( a[i..i+s-1] for i in [0..a.length - 1 ] by s)
