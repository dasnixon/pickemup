techStack.factory 'TechStack', ($resource) ->
  editTechStack: $resource('/companies/:company_id/tech_stacks/:tech_stack_id/:action',
    {company_id: '@company_id', tech_stack_id: '@tech_stack_id', action: '@action'},
    'get':    {method:'GET'},
    'update': {method:'PUT'},
    'retrieveTechStack': {method: 'GET'}
  )
  newTechStack: $resource('/companies/:company_id/tech_stacks/new',
    {company_id: '@company_id'},
    'new': {method:'GET'},
  )
  createTechStack: $resource('/companies/:company_id/tech_stacks',
    {company_id: '@company_id'},
    'create': {method: 'POST'}
  )
