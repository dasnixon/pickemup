userEdit.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)

  $stateProvider
    .state "edit",
      url: "/users/:id/edit"
      views:
        "":
          controller: "UsersController"
          templateUrl: "/assets/users/edit.html.erb"

  $urlRouterProvider.otherwise("/")

preference_app.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)

  $stateProvider
    .state "edit_preferences",
      url: "/users/:id/preferences"
      views:
        "":
          controller: "PreferencesController"
          templateUrl: "/assets/preferences/edit.html.erb"

  $urlRouterProvider.otherwise("/")

jobListing.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)

  $stateProvider
    .state "edit",
      url: "/companies/:company_id/job_listings/:job_listing_id/edit"
      views:
        "":
          controller: "JobListingCtrl"
          templateUrl: "/assets/job_listings/edit.html.erb",

    .state "new",
      url: "/companies/:company_id/job_listings/new"
      views:
        "":
          controller: "JobListingCtrl"
          templateUrl: "/assets/job_listings/new.html.erb",

  $urlRouterProvider.otherwise("/")


techStack.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)

  $stateProvider
    .state "edit",
      url: "/companies/:company_id/tech_stacks/:tech_stack_id/edit"
      views:
        "":
          controller: "TechStackCtrl"
          templateUrl: "/assets/tech_stacks/edit.html.erb",

    .state "new",
      url: "/companies/:company_id/tech_stacks/new"
      views:
        "":
          controller: "TechStackCtrl"
          templateUrl: "/assets/tech_stacks/new.html.erb",

  $urlRouterProvider.otherwise("/")
