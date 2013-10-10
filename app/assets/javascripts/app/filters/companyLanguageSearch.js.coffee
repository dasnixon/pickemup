angular.module('languageCompanySearch', []).filter 'language', ->
  (scope, keyword) ->
    if scope?
      if keyword?
        return _.filter scope, (match) ->
          found_matches = _.find match.acceptable_languages, (lang) ->
            pattern = keyword.replace(/\s+/, "|")
            regex = new RegExp(pattern, 'ig')
            lang.match(regex)
          found_matches?
      else
        return scope
