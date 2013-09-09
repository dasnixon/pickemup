# == Schema Information
#
# Table name: positions
#
#  id           :uuid             not null, primary key
#  industry     :string(255)
#  company_type :string(255)
#  name         :string(255)
#  size         :string(255)
#  position_key :string(255)
#  is_current   :boolean
#  title        :string(255)
#  summary      :text
#  start_year   :string(255)
#  start_month  :string(255)
#  profile_id   :uuid
#  created_at   :datetime
#  updated_at   :datetime
#

class Position < ActiveRecord::Base
  belongs_to :profile

  #CRUD operations for a user's linkedin positions
  def self.from_omniauth(profile, id, position_keys=nil)
    if profile.positions.total > 0
      Position.remove_positions(profile.positions.all, position_keys) if position_keys.present?
      profile.positions.all.each do |position|
        company_info = position.company
        pos = Position.where(position_key: company_info.id.to_s, profile_id: id).first_or_initialize
        pos.update(
          industry:      company_info.industry,
          name:          company_info.name,
          size:          company_info.size,
          company_type:  company_info.type,
          is_current:    position.is_current,
          start_year:    position.start_date.year,
          start_month:   position.start_date.month,
          summary:       position.summary,
          title:         position.title
        )
      end
    end
  end

  #remove any positions that we have on our system that have been removed from
  #the user's linkedin positions so we always have up-to-date information
  def self.remove_positions(positions, position_keys)
    (position_keys - positions.collect { |pos| pos.company.id.to_s }).each do |diff_id|
      Position.find_by(position_key: diff_id).try(:destroy)
    end
  end
end
