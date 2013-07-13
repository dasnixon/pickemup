app = angular.module("Pickemup", ["ngResource"])

app.factory "Skill", ["$resource", ($resource) ->
  $resource("/users/:id/skills", {id: "@id"})
]
