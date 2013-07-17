skill_app.factory 'Skill', ($resource) ->
  $resource '/users/:id/skills',
    {id: '@id'},
    'query':  {method:'GET', isArray:true}
