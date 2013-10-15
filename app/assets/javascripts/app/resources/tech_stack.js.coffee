techStack.factory('TechStack', ['$resource', ($resource) ->
  editTechStack: $resource('/companies/:company_id/tech_stacks/:tech_stack_id/:action.json',
    {company_id: '@company_id', tech_stack_id: '@tech_stack_id', action: '@action'},
    'get':    {method:'GET'},
    'update': {method:'PUT'},
    'retrieveTechStack': {method: 'GET'}
  )
  newTechStack: $resource('/companies/:company_id/tech_stacks/new.json',
    {company_id: '@company_id'},
    'new': {method:'GET'},
  )
  createTechStack: $resource('/companies/:company_id/tech_stacks.json',
    {company_id: '@company_id'},
    'create': {method: 'POST'}
  )
])
