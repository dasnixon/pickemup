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
    "#{listing.fulltime? ? 'Fulltime ' : 'Part-time '}#{listing.remote? ? 'Remote ' : ''}#{listing.job_title} - #{listing.locations.present? ? listing.locations.join(', ') : "Unspecified Location"}"
  end

  def default_job_listing_company(listing, company, user)
    "<p>Hey #{user.name},</p><p>We are messaging you regarding a #{listing.fulltime? ? 'fulltime' : 'part-time'}
    #{listing.remote? ? 'remote' : ''} #{listing.job_title} position in #{listing.location}. We think that you
    would be an ideal candidate here at #{company.name} based on your preferences. You can find more information about us
    #{link_to 'here', company_path(id: company.id) } and read more about the job listing
    #{link_to 'here', company_job_listing_path(comapny_id: company.id, id: listing.id)}. We hope to hear
    back from you as soon as possible, and we can work out an ideal time to schedule an interview.</p><p>Thanks.</p>"
  end
end
