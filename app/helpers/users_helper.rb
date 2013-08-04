module UsersHelper
  def user_benefits(preference)
    benefits = %w(healthcare dentalcare visioncare life_insurance retirement paid_vacation equity bonuses).collect do |benefit|
      benefit.gsub(/_/, ' ').capitalize if preference.send("#{benefit}?")
    end
    benefits.compact.join(', ')
  end

  def user_bio(user, preference)
    first_block = []
    second_block = []
    third_block = []
    fourth_sentence = ""
    @at_company_set = false
    @gone_already = false
    set_initial_statements(user, first_block, preference)
    positions_statement(first_block, preference)
    locations_statement(first_block, preference)
    first_sentence = first_block.join(' ')
    settings_statement(second_block, preference)
    dress_codes_statment(second_block, preference)
    company_size_statement(second_block, preference)
    industries_statement(second_block, preference)
    second_block.blank? ? second_block << "." : second_block.last.insert(-1, ".")
    second_sentence = second_block.to_sentence(two_words_connector: ' and ', last_word_connector: ', and ')
    availability_statement(user, third_block, preference)
    work_hours_statement(third_block, preference)
    salary_statement(third_block, preference)
    third_block.last.insert(-1, '.')
    third_sentence = third_block.to_sentence(two_words_connector: ' and ', last_word_connector: ', and ')
    fourth_sentence = " It would also be preferred if the company makes open source contributions." if preference.open_source?
    first_sentence + second_sentence + third_sentence + fourth_sentence
  end

  def salary_statement(bio, preference)
    bio << "would like to make around #{number_to_currency(preference.expected_salary)}" if preference.expected_salary > 0
  end

  def work_hours_statement(bio, preference)
    bio << "wants to work #{pluralize(preference.work_hours, 'hour')} a week" if preference.work_hours > 0
  end

  def availability_statement(user, bio, preference)
    bio << " #{user.name} can start #{preference.potential_availability == 0 ? "immediately" : "in #{pluralize(preference.potential_availability, 'week')}"}"
  end

  def positions_statement(bio, preference)
    if preference.positions.present?
      bio << " as #{preference.positions.to_sentence(two_words_connector: ' or ', last_word_connector: ', or ').indefinitize.downcase}"
    end
  end

  def locations_statement(bio, preference)
    if preference.locations.present?
      bio << " in #{preference.locations.to_sentence(two_words_connector: ' or ', last_word_connector: ', or ')}"
    end
  end

  def set_initial_statements(user, bio, preference)
    bio << "#{user.name} is looking for a #{preference.remote? ? 'remote' : '' } #{preference.fulltime? ? 'fulltime' : 'part-time'} job"
  end

  def settings_statement(bio, preference)
    if preference.settings.present?
      add_company_info(bio, preference)
      @gone_already = true
      bio.last << " with #{preference.settings.to_sentence(two_words_connector: ' or ', last_word_connector: ', or ').indefinitize.downcase} setting"
    end
  end

  def dress_codes_statment(bio, preference)
    if preference.dress_codes.present?
      add_company_info(bio, preference)
      if @gone_already
        bio << " a #{preference.dress_codes.to_sentence(two_words_connector: ' or ', last_word_connector: ', or ').downcase} dress code"
      else
        @gone_already = true
        bio.last << " with a #{preference.dress_codes.to_sentence(two_words_connector: ' or ', last_word_connector: ', or ').downcase} dress code"
      end
    end
  end

  def industries_statement(bio, preference)
    if preference.industries.present?
      add_company_info(bio, preference)
      @gone_already = true
      bio << " in the #{preference.industries.to_sentence(two_words_connector: ' or ', last_word_connector: ', or ').downcase} industry"
    end
  end

  def company_size_statement(bio, preference)
    if preference.company_size.present?
      add_company_info(bio, preference)
      company_sizes = preference.company_size.collect { |c| c.split("-") }.flatten.collect { |num| num.to_i }.sort
      min_size = company_sizes.first
      max_size = company_sizes.last
      if min_size == max_size
        if @gone_already
          bio << " more than 500 employees"
        else
          @gone_already = true
          bio.last << " with more than 500 employees"
        end
      elsif max_size == "501"
        if @gone_already
          bio << " #{min_size} or more employees"
        else
          @gone_already = true
          bio.last << " with #{min_size} or more employees"
        end
      else
        if @gone_already
          bio << " #{min_size} to #{max_size} employees"
        else
          @gone_already = true
          bio.last << " with #{min_size} to #{max_size} employees"
        end
      end
    end
  end

  def add_company_info(bio, preference)
    unless @at_company_set
      bio << ", at a #{describe_company_type(preference)} company"
      @at_company_set = true
    end
  end

  def describe_company_type(preference)
    preference.company_types.collect { |t| t.gsub(/Business/, '').downcase.strip }.to_sentence(two_words_connector: ' or ', last_word_connector: ', or ')
  end
end
