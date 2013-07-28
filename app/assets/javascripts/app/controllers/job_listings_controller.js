jobListing.controller("JobListingCtrl", ['$scope', '$http', '$state', '$stateParams', '$location', 'JobListing', function($scope, $http, $state, $stateParams, $location, JobListing) {
  $scope.jobListing     = {}
  $scope.errors         = []
  $scope.success        = ''
  $scope.error_updating = ''

  if ($state.current.name == "edit") {
    JobListing.editListing.retrieveListing({
      job_listing_id: $stateParams['job_listing_id'],
      company_id: $stateParams['company_id'],
      action: 'retrieve_listing'
    }, function(response) {
       response.acceptable_languages = chunk(response.acceptable_languages, 6)
       response.practices = chunk(response.practices, 6)
       response.special_characteristics = chunk(response.special_characteristics, 6)
       response.experience_level = chunk(response.experience_level, 5)
       response.position_type = chunk(response.position_type, 5)
       response.perks = chunk(response.perks, 6)
       $scope.data = response
    });
    return $scope.update = function() {
      JobListing.editListing.update({
        company_id: $stateParams['company_id'],
        job_listing_id: $stateParams['job_listing_id'],
        action: 'update_listing',
        job_listing: {
          job_title: $scope.data.job_title,
          job_description: $scope.data.job_description,
          location: $scope.data.location,
          position_type: unchunk($scope.data.position_type),
          experience_level: unchunk($scope.data.experience_level),
          salary_range_low: $scope.data.salary_range_low,
          salary_range_high: $scope.data.salary_range_high,
          vacation_days: $scope.data.vacation_days,
          healthcare: $scope.data.healthcare,
          dental: $scope.data.dental,
          vision: $scope.data.vision,
          life_insurance: $scope.data.life_insurance,
          retirement: $scope.data.retirement,
          equity: $scope.data.equity,
          bonuses: $scope.data.bonuses,
          perks: unchunk($scope.data.perks),
          fulltime: $scope.data.fulltime,
          estimated_work_hours: $scope.data.estimated_work_hours,
          remote: $scope.data.remote,
          hiring_time: $scope.data.hiring_time,
          special_characteristics: unchunk($scope.data.special_characteristics),
          acceptable_languages: unchunk($scope.data.acceptable_languages),
          practices: unchunk($scope.data.practices)
        }},
        function(response) {
          $location.path("/companies/" + $stateParams['company_id'] + "/job_listings/" + $stateParams['job_listing_id'])
          return $scope.success;
        }
    )};
  } else if($state.current.name == "new") {
    JobListing.newListing.new({
      company_id: $stateParams['company_id'],
      action: 'new'
    }, function(response) {
       response.acceptable_languages = chunk(response.acceptable_languages, 6)
       response.practices = chunk(response.practices, 6)
       response.special_characteristics = chunk(response.special_characteristics, 6)
       response.experience_level = chunk(response.experience_level, 5)
       response.position_type = chunk(response.position_type, 5)
       response.perks = chunk(response.perks, 6)
       $scope.data = response
    });
    return $scope.create = function() {
      JobListing.createListing.create({
        company_id: $stateParams['company_id'],
        action: 'create',
        job_listing: {
          job_title: $scope.data.job_title,
          job_description: $scope.data.job_description,
          location: $scope.data.location,
          position_type: unchunk($scope.data.position_type),
          experience_level: unchunk($scope.data.experience_level),
          salary_range_low: $scope.data.salary_range_low,
          salary_range_high: $scope.data.salary_range_high,
          vacation_days: $scope.data.vacation_days,
          healthcare: $scope.data.healthcare,
          dental: $scope.data.dental,
          vision: $scope.data.vision,
          life_insurance: $scope.data.life_insurance,
          retirement: $scope.data.retirement,
          equity: $scope.data.equity,
          bonuses: $scope.data.bonuses,
          perks: unchunk($scope.data.perks),
          fulltime: $scope.data.fulltime,
          estimated_work_hours: $scope.data.estimated_work_hours,
          remote: $scope.data.remote,
          hiring_time: $scope.data.hiring_time,
          special_characteristics: unchunk($scope.data.special_characteristics),
          acceptable_languages: unchunk($scope.data.acceptable_languages),
          practices: unchunk($scope.data.practices)
        }},
        function(response) {
          $location.path("/companies/" + $stateParams['company_id'] + "/job_listings/")
          return $scope.success;
        }
    )};
  }
}]);
