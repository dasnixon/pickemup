module CompaniesHelper
  def job_listing_benefits(listing)
    benefits = %w(healthcare dental vision life_insurance retirement sponsorship_available).collect do |benefit|
      benefit.gsub(/_/, ' ').capitalize if listing.send("#{benefit}?")
    end
    if listing.vacation_days.present? && !listing.vacation_days.zero?
      benefits << "#{pluralize(listing.vacation_days, 'vacation day')}"
    end
    if listing.equity && listing.equity != 'None'
      benefits << "#{listing.equity} equity"
    end
    if listing.bonuses && listing.bonuses != 'None'
      case listing.bonuses
        when 'Something else'
          benefits << "Bonuses"
        else
          benefits << "#{listing.bonuses} in bonuses"
      end
    end
    benefits.compact.join(', ')
  end

  def job_listing_title(listing)
    "#{listing.fulltime? ? 'Fulltime ' : 'Part-time '}#{listing.remote? ? 'Remote ' : ''}#{listing.job_title} - #{listing.location || "Unspecified Location"}"
  end

  def default_job_listing_company(listing, company, user)
    "SWEET"
  end
end
