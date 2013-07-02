# == Schema Information
#
# Table name: positions
#
#  id           :integer          not null, primary key
#  industry     :string(255)
#  company_type :string(255)
#  name         :string(255)
#  size         :string(255)
#  company_key  :string(255)
#  is_current   :boolean
#  title        :string(255)
#  summary      :text
#  start_year   :string(255)
#  start_month  :string(255)
#  profile_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Position < ActiveRecord::Base
  belongs_to :profile

  def self.from_omniauth(profile, id)
    if profile['positions'].present?
      profile['positions']['values'].each do |position|
        Position.create(profile_id: id) do |p|
          company_info   = position['company']
          p.industry     = company_info['industry']
          p.company_type = company_info['type']
          p.name         = company_info['name']
          p.size         = company_info['size']
          p.company_type = company_info['type']
          p.company_key  = company_info['id']
          p.is_current   = position['isCurrent']
          p.start_year   = position['startDate']['year']
          p.start_month  = position['startDate']['month']
          p.summary      = position['summary']
          p.title        = position['title']
        end
      end
    end
  end
end
