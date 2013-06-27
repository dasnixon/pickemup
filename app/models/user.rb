class User < ActiveRecord::Base
  def self.from_omniauth(auth)
    User.where(auth.slice(:provider, :uid)).first_or_create do |user|
      info                            = auth.info
      extra_info                      = auth.extra.raw_info
      user.name                       = info.name
      user.nickname                   = info.nickname
      user.email                      = info.email
      user.github_profile_image       = info.image
      user.location                   = extra_info.location
      user.blog                       = extra_info.blog
      user.current_company            = extra_info.company
      user.hireable                   = extra_info.hireable
      user.github_bio                 = extra_info.bio
      user.public_repos_count         = extra_info.public_repos
      user.github_number_followers    = extra_info.followers
      user.github_number_following    = extra_info.following
      user.github_number_public_gists = extra_info.public_gists
      user.github_token               = auth.credentials.token
    end
  end

  def update_linkedin_info(auth)
    self.update_attributes(
      linkedin_token: auth.credentials.token,
      headline: auth.info.description,
      industry: auth.extra.raw_info.industry,
      linkedin_uid: auth.uid,
      linkedin_profile_url: auth.extra.raw_info.publicProfileUrl
    )
  end

  def has_linkedin_synced?
    self.linkedin_uid.present?
  end
end
