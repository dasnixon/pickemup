@preference_app = angular.module('Preferences', ['ngResource', 'ui.compat', 'csrf', 'utf8'])
@jobListing = angular.module('JobListing', ['ngResource', 'ui.compat', 'ck-editor', 'csrf', 'utf8', 'igTruncate', 'ui-slider', 'langSearch'])
@techStack = angular.module('TechStack', ['ngResource', 'ui.compat', 'csrf', 'utf8'])
@userEdit = angular.module('Users', ['ngResource', 'ui.compat', 'ck-editor', 'csrf', 'utf8', 'igTruncate'])

@chunk = (a,s) ->
  if a
    if a.length == 0
      []
    else
      ( a[i..i+s-1] for i in [0..a.length - 1 ] by s)

@unchunk = (a) ->
  merged = []
  merged.concat.apply(merged, a)

#Convert string into a money format with commas 60000 -> 60,000
@addCommas = (nStr) ->
  nStr += ""
  x = nStr.split(".")
  x1 = x[0]
  x2 = (if x.length > 1 then "." + x[1] else "")
  rgx = /(\d+)(\d{3})/
  x1 = x1.replace(rgx, "$1" + "," + "$2")  while rgx.test(x1)
  x1 + x2

@changeLocation = (scope, location, url, forceReload) ->
  $scope = $scope or angular.element(document).scope()
  if forceReload or $scope.$$phase
    window.location = url
  else
    $location.path(url)
    $scope.$apply()

@scoreClass = (score) ->
  score = if score? then parseInt(score) else 0

  if 0 <= score <= 24
    'poor-score-color'
  else if 25 <= score <= 49
    'low-score-color'
  else if 50 <= score <= 74
    'medium-score-color'
  else
    'high-score-color'
