@Skills = ($scope, Skill) ->
  $scope.init = (user_id) ->
    Skill.query(id: user_id, (data) ->
      $scope.profile = data[0].skills
    )

  $scope.$watch 'profile', ->
    $scope.rows = chunk $scope.profile, 6
