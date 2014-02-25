require 'spec_helper'

describe Algorithm do
  let(:user) { create(:user) }
  let(:preference) { user.preference }
  let(:job_listing) { create(:job_listing, dental: true, healthcare: true, vision: true, life_insurance: true, equity: '1% - 5%', bonuses: '1-10% of base salary',
                             vacation_days: 0, retirement: true, special_characteristics: ['Open Source Committer'], company: company) }
  let(:company) { create(:company) }
  let(:algorithm) { Algorithm.new(preference, job_listing, run_score: false, company: company) }

  before :each do
    preference.update(dental: true, healthcare: true, vision: true, life_insurance: true,
                      vacation_days: false, bonuses: true, retirement: true, open_source: true, equity: true)
  end

  describe '#benefits_matching_count' do
    context 'all matches' do
      it 'returns the number of matching attributes for benefit attributes' do
        algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length
      end
    end
    %w(dental vision healthcare life_insurance retirement).each do |attr|
      context "#{attr}" do
        context "#{attr} set true, user cares about #{attr}" do
          before :each do
            preference.send("#{attr}=", true)
          end
          context 'mismatch' do
            it 'returns 1 less than # of comparators' do
              job_listing.send("#{attr}=", false)
              algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length - 1
            end
          end
          context 'match' do
            it 'returns full # of comparators' do
              algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length
            end
          end
        end
        context "#{attr} set false, user doesn't care about #{attr}" do
          before :each do
            preference.send("#{attr}=", false)
          end
          it 'always matches' do
            algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length
          end
        end
      end
    end
    context 'vacation_days' do
      context 'user wants vacation days' do
        context 'match' do
          it 'returns full # of comparators' do
            preference.vacation_days = true
            job_listing.vacation_days = 15
            algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length
          end
        end
        context 'mismatch' do
          it 'returns 1 less than # of comparators' do
            preference.vacation_days = true
            job_listing.vacation_days = 0
            algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length - 1
          end
        end
      end
      context 'user does not care about vacation days' do
        it 'always returns full # of comparators' do
          preference.vacation_days = false
          job_listing.vacation_days = 0
          algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length
        end
      end
    end

    context 'equity' do
      context 'match' do
        it 'returns full # of comparators' do
          preference.equity = true
          job_listing.equity = '1% - 5%'
          algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length
        end
      end
      context 'mismatch' do
        it 'returns 1 less than # of comparators' do
          preference.equity = true
          job_listing.equity = 'None'
          algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length - 1
        end
      end
      context "user does not care about equity" do
        it 'always returns full # of comparators' do
          preference.equity = false
          job_listing.equity = '1% - 5%'
          algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length
        end
      end
    end

    context 'bonuses' do
      context 'match' do
        it 'returns full # of comparators' do
          preference.bonuses = true
          job_listing.bonuses = '1-10% of base salary'
          algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length
        end
      end
      context 'mismatch' do
        it 'returns 1 less than # of comparators' do
          preference.bonuses = true
          job_listing.bonuses = 'None'
          algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length - 1
        end
      end
      context "user does not care about bonuses" do
        it 'always returns full # of comparators' do
          preference.bonuses = false
          job_listing.bonuses = '1-10% of base salary'
          algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length
        end
      end
    end

    context 'open_source' do
      context 'user wants a company that makes open source contributions' do
        before :each do
          preference.open_source = true
        end
        context 'match' do
          it 'returns full # of comparators' do
            job_listing.special_characteristics = ['Open Source Committer']
            algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length
          end
        end
        context 'mismatch' do
          it 'returns 1 less than # of comparators' do
            job_listing.special_characteristics = ['We hate open source']
            algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length - 1
          end
        end
      end
      context 'user does not care if a company makes open source contributions' do
        it 'always returns full # of comparators' do
          preference.open_source = false
          algorithm.benefits_matching_count.should eq Algorithm::BOOLEAN_COMPARATORS.length
        end
      end
    end
  end

  describe '#valid_salary?' do
    context 'valid, within the job listings specified salary range' do
      before :each do
        preference.expected_salary = 100000
        job_listing.salary_range_low = 95000
        job_listing.salary_range_high = 110000
      end
      it 'returns true' do
        algorithm.valid_salary?.should be_true
      end
    end
    context 'invalid, outside the job listings specified salary range' do
      before :each do
        preference.expected_salary = 100000
        job_listing.salary_range_low = 105000
        job_listing.salary_range_high = 110000
      end
      it 'returns false' do
        algorithm.valid_salary?.should be_false
      end
    end
  end

  describe '#valid_work_hours?' do
    context 'valid, within +/- 5 hours of expected work hours' do
      before :each do
        preference.work_hours = 40
        job_listing.estimated_work_hours = 45
      end
      it 'returns true' do
        algorithm.valid_work_hours?.should be_true
      end
    end
    context 'invalid, outside the +/- 5 hours of expected work hours' do
      before :each do
        preference.work_hours = 40
        job_listing.estimated_work_hours = 50
      end
      it 'returns false' do
        algorithm.valid_work_hours?.should be_false
      end
    end
  end

  describe '#valid_position?' do
    before :each do
      algorithm.stub(:valid_position_type?).and_return(true)
    end
    context 'invalid position' do
      context 'incorrect experience levels' do
        context 'no intersected matches' do
          before :each do
            preference.experience_levels = ['Mid-level']
            job_listing.experience_levels = ['Senior-level']
          end
          it('returns false') { algorithm.valid_position?.should be_false }
        end
        context 'amount of experience levels preferred is out of range of amount job listing specifies' do
          before :each do
            preference.experience_levels = ['Mid-level', 'Senior-level', 'Junior', 'Executive']
            job_listing.experience_levels = ['Senior-level']
          end
          it('returns false') { algorithm.valid_position?.should be_false }
        end
      end
      context 'correct experience levels' do
        before :each do
          preference.experience_levels = ['Mid-level', 'Senior-level']
          job_listing.experience_levels = ['Senior-level']
        end
        it('returns true') { algorithm.valid_position?.should be_true }
      end
    end
  end

  describe '#valid_position_type?' do
    context 'invalid position type' do
      context 'no intersected matches' do
        before :each do
          preference.position_titles = ['Software Engineer']
          job_listing.position_titles = ['DevOps Engineer']
        end
        it('returns false') { algorithm.valid_position_type?.should be_false }
      end
      context 'amount of positions preferred is out of range of amount job listing specifies' do
        before :each do
          preference.position_titles = ['Software Engineer', 'QA Engineer', 'Architect', 'CEO']
          job_listing.position_titles = ['Software Engineer']
        end
        it('returns false') { algorithm.valid_position_type?.should be_false }
      end
    end
    context 'valid position type' do
      before :each do
        preference.position_titles = ['Software Engineer', 'QA Engineer']
        job_listing.position_titles = ['Software Engineer']
      end
      it('returns true') { algorithm.valid_position_type?.should be_true }
    end
  end

  describe '#valid_vacation_days?' do
    context 'user wants vacation days' do
      context 'job listings offers no vacation' do
        before :each do
          preference.vacation_days = true
          job_listing.vacation_days = 0
        end
        it('returns false') { algorithm.valid_vacation_days?.should be_false }
      end
      context 'job listing offers vacation' do
        before :each do
          preference.vacation_days = true
          job_listing.vacation_days = 10
        end
        it('returns true') { algorithm.valid_vacation_days?.should be_true }
      end
    end
    context 'user does not care about vacation' do
      before :each do
        preference.vacation_days = false
      end
      it('always returns true') { algorithm.valid_vacation_days?.should be_true }
    end
  end

  describe '#valid_perks?' do
    context 'invalid perks' do
      context 'no intersected matches' do
        before :each do
          preference.perks = ['Kegs']
          job_listing.perks = ['Snacks']
        end
        it('returns false') { algorithm.valid_perks?.should be_false }
      end
      context 'amount of perks preferred is out of range of amount job listing specifies' do
        before :each do
          preference.perks = ['Kegs', 'Work from Home', 'Lunch Stipend', 'Phone Stipend']
          job_listing.perks = ['Work from Home']
        end
        it('returns false') { algorithm.valid_perks?.should be_false }
      end
    end
    context 'valid perks' do
      before :each do
        preference.perks = ['Kegs', 'Snacks']
        job_listing.perks = ['Kegs']
      end
      it('returns true') { algorithm.valid_perks?.should be_true }
    end
  end

  describe '#valid_practices?' do
    context 'invalid practices' do
      context 'no intersected matches' do
        before :each do
          preference.practices = ['Agile Development']
          job_listing.practices = ['Pair Programming']
        end
        it('returns false') { algorithm.valid_practices?.should be_false }
      end
      context 'amount of practices preferred is out of range of amount job listing specifies' do
        before :each do
          preference.practices = ['Agile Development', 'Pair Programming', 'Cowboy Coding', 'Extreme Programming']
          job_listing.practices = ['Agile Development']
        end
        it('returns false') { algorithm.valid_practices?.should be_false }
      end
    end
    context 'valid practices' do
      before :each do
        preference.practices = ['Agile Development', 'Pair Programming']
        job_listing.practices = ['Agile Development']
      end
      it('returns true') { algorithm.valid_practices?.should be_true }
    end
  end

  describe '#valid_availability_to_start?' do
    context 'user wants to start near the same time the job listing specifies' do
      before :each do
        preference.potential_availability = 2
        job_listing.hiring_time = 1
      end
      it('returns true') { algorithm.valid_availability_to_start?.should be_true }
    end
    context 'user does not want to start when the job listing specifies' do
      before :each do
        preference.potential_availability = 4
        job_listing.hiring_time = 2
      end
      it('returns false') { algorithm.valid_availability_to_start?.should be_false }
    end
  end

  describe '#preferred_company_size?' do
    context 'valid company size for user based on company' do
      context 'user has no preference for a company size' do
        before :each do
          preference.company_size = []
        end
        it('returns true') { algorithm.preferred_company_size?.should be_true }
      end
      context 'user will work at a company of any size' do
        before :each do
          preference.company_size = Preference::COMPANY_SIZE
        end
        it('returns true') { algorithm.preferred_company_size?.should be_true }
      end
      context 'user prefers the size of the company' do
        context '1-10 employees' do
          before :each do
            company.num_employees = '5'
            preference.company_size = ['1-10 Employees', '11-50 Employees']
          end
          it('returns true') { algorithm.preferred_company_size?.should be_true }
        end
        context '11-50 employees' do
          before :each do
            company.num_employees = '25'
            preference.company_size = ['1-10 Employees', '11-50 Employees']
          end
          it('returns true') { algorithm.preferred_company_size?.should be_true }
        end
      end
    end
    context 'user does not prefer company size' do
      before :each do
        company.num_employees = '500'
        preference.company_size = ['1-10 Employees', '11-50 Employees']
      end
      it('returns false') { algorithm.preferred_company_size?.should be_false }
    end
  end

  describe '#preferred_company_industry?' do
    context 'preferred industry for user based on company' do
      context 'user has no preference for the industry they work in' do
        before :each do
          preference.industries = []
        end
        it('returns true') { algorithm.preferred_company_industry?.should be_true }
      end
      context 'company has not specified an industry' do
        before :each do
          company.industry = nil
        end
        it('returns true') { algorithm.preferred_company_industry?.should be_true }
      end
      context 'user wants to be in the same industry as company' do
        context '1-10 employees' do
          before :each do
            company.industry = 'Consumer Technology'
            preference.industries = ['Medical', 'Sports', 'Consumer Technology']
          end
          it('returns true') { algorithm.preferred_company_industry?.should be_true }
        end
      end
    end
    context 'user does not want to work in same industry as company' do
      before :each do
        company.industry = 'Non-profit'
        preference.industries = ['Medical', 'Sports', 'Consumer Technology']
      end
      it('returns false') { algorithm.preferred_company_industry?.should be_false }
    end
  end

  describe '#valid_locations?' do
    context 'user preferes the location for the job listing' do
      context 'willing to relocate' do
        before :each do
          preference.willing_to_relocate = true
        end
        it('returns true') { algorithm.valid_locations?.should be_true }
      end
      context 'user does not care about locations preference' do
        before :each do
          preference.willing_to_relocate = false
          preference.locations = []
        end
        it('returns true') { algorithm.valid_locations?.should be_true }
      end
      context 'job listing location is one of the preferred user locations' do
        before :each do
          preference.willing_to_relocate = false
          preference.locations = ['San Francisco, CA']
          job_listing.locations = ['San Francisco, CA']
        end
        it('returns true') { algorithm.valid_locations?.should be_true }
      end
    end
    context 'user does not prefer the location for the job listing' do
      before :each do
        preference.willing_to_relocate = false
        preference.locations = ['Los Angeles, CA']
        job_listing.locations = ['San Francisco, CA']
      end
      it('returns false') { algorithm.valid_locations?.should be_false }
    end
  end

  describe '#preferred_company_type?' do
    context 'user preferes the type of company' do
      context 'user has no preference of the type of company' do
        before :each do
          preference.company_types = []
        end
        it('returns true') { algorithm.preferred_company_type?.should be_true }
      end
      context 'company has not specified their type of company' do
        before :each do
          preference.company_types = ['Angel Invested']
          company.size_definition = nil
        end
        it('returns true') { algorithm.preferred_company_type?.should be_true }
      end
      context 'the company types the user preferes matches with the company type' do
        before :each do
          preference.company_types = ['Angel Invested', 'Crowdfunded']
          company.size_definition = 'Crowdfunded'
        end
        it('returns true') { algorithm.preferred_company_type?.should be_true }
      end
    end
    context 'the company types the user prefers do not match the company type' do
      before :each do
        preference.company_types = ['Publicly-Owned Business']
        company.size_definition = 'Crowdfunded'
      end
      it('returns false') { algorithm.preferred_company_type?.should be_false }
    end
  end

  describe '#company_preferred_count' do
    it 'returns the count of user with company matches, 2' do
      expect(algorithm).to receive(:preferred_company_size?).and_return(true)
      expect(algorithm).to receive(:preferred_company_industry?).and_return(true)
      expect(algorithm).to receive(:preferred_company_type?).and_return(false)
      algorithm.company_preferred_count.should eq 2
    end
    it 'returns the count of user with company matches, 0' do
      expect(algorithm).to receive(:preferred_company_size?).and_return(false)
      expect(algorithm).to receive(:preferred_company_industry?).and_return(false)
      expect(algorithm).to receive(:preferred_company_type?).and_return(false)
      algorithm.company_preferred_count.should eq 0
    end
  end
end
