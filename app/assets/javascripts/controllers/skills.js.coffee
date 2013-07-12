chunk = (a,s)->
  if a
    if a.length == 0
      []
    else
      ( a[i..i+s-1] for i in [0..a.length - 1 ] by s)

@Skills = ($scope, Skill) ->
  $scope.init = (user_id) ->
    Skill.query(id: user_id, isArray: true, (data) ->
      $scope.profile = data[0].skills
    )

  $scope.$watch 'profile', ->
    $scope.rows = chunk $scope.profile, 6
