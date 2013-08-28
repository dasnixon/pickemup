require 'spec_helper'

describe UserAlgorithm do
  let(:preference) { create(:preference, dentalcare: true, healthcare: true, visioncare: true, life_insurance: true,
                            paid_vacation: false, bonuses: true, retirement: true, open_source: true, equity: true) }
  let(:job_listing) { create(:job_listing, dental: true, healthcare: true, vision: true, life_insurance: true,
                             vacation_days: 0, bonuses: 'Yes', retirement: true, equity: 'Yes', special_characteristics: ['Open Source Committer']) }
  before :each do
    preference.extend(UserAlgorithm)
  end
  describe '#benefits_matching_count' do
    context 'all matches' do
      it 'returns the number of matching attributes for benefit attributes' do
        preference.benefits_matching_count(job_listing).should eq UserAlgorithm::BOOLEAN_COMPARATORS.length
      end
    end
    %w(dental vision healthcare life_insurance retirement).each do |attr|
      case attr
        when 'dental'
          preference_attr = 'dentalcare'
        when 'vision'
          preference_attr = 'visioncare'
        else
          preference_attr = attr
      end
      context "#{attr}" do
        context "#{attr} set true, user cares about #{attr}" do
          before :each do
            preference.send("#{preference_attr}=", true)
          end
          context 'mismatch' do
            it 'returns 1 less than # of comparators' do
              job_listing.send("#{attr}=", false)
              preference.benefits_matching_count(job_listing).should eq UserAlgorithm::BOOLEAN_COMPARATORS.length - 1
            end
          end
          context 'match' do
            it 'returns full # of comparators' do
              preference.benefits_matching_count(job_listing).should eq UserAlgorithm::BOOLEAN_COMPARATORS.length
            end
          end
        end
        context "#{attr} set false, user doesn't care about #{attr}" do
          before :each do
            preference.send("#{preference_attr}=", false)
          end
          it 'always matches' do
            preference.benefits_matching_count(job_listing).should eq UserAlgorithm::BOOLEAN_COMPARATORS.length
          end
        end
      end
    end
    context 'paid_vacation' do
      context 'user wants vacation days' do
        context 'match' do
          it 'returns full # of comparators' do
            preference.paid_vacation = true
            job_listing.vacation_days = 15
            preference.benefits_matching_count(job_listing).should eq UserAlgorithm::BOOLEAN_COMPARATORS.length
          end
        end
        context 'mismatch' do
          it 'returns 1 less than # of comparators' do
            preference.paid_vacation = true
            job_listing.vacation_days = 0
            preference.benefits_matching_count(job_listing).should eq UserAlgorithm::BOOLEAN_COMPARATORS.length - 1
          end
        end
      end
      context 'user does not care about vacation days' do
        it 'always returns full # of comparators' do
          preference.paid_vacation = false
          job_listing.vacation_days = 0
          preference.benefits_matching_count(job_listing).should eq UserAlgorithm::BOOLEAN_COMPARATORS.length
        end
      end
    end
    %w(equity bonuses).each do |attr|
      context "#{attr}" do
        context "user wants #{attr}" do
          context 'match' do
            it 'returns full # of comparators' do
              preference.send("#{attr}=", true)
              job_listing.send("#{attr}=", 'Yes')
              preference.benefits_matching_count(job_listing).should eq UserAlgorithm::BOOLEAN_COMPARATORS.length
            end
          end
          context 'mismatch' do
            it 'returns 1 less than # of comparators' do
              preference.send("#{attr}=", true)
              job_listing.send("#{attr}=", 'None')
              preference.benefits_matching_count(job_listing).should eq UserAlgorithm::BOOLEAN_COMPARATORS.length - 1
            end
          end
        end
        context "user does not care about #{attr}" do
          it 'always returns full # of comparators' do
            preference.send("#{attr}=", false)
            preference.benefits_matching_count(job_listing).should eq UserAlgorithm::BOOLEAN_COMPARATORS.length
          end
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
            preference.benefits_matching_count(job_listing).should eq UserAlgorithm::BOOLEAN_COMPARATORS.length
          end
        end
        context 'mismatch' do
          it 'returns 1 less than # of comparators' do
            job_listing.special_characteristics = ['We hate open source']
            preference.benefits_matching_count(job_listing).should eq UserAlgorithm::BOOLEAN_COMPARATORS.length - 1
          end
        end
      end
      context 'user does not care if a company makes open source contributions' do
        it 'always returns full # of comparators' do
          preference.open_source = false
          preference.benefits_matching_count(job_listing).should eq UserAlgorithm::BOOLEAN_COMPARATORS.length
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
        preference.valid_salary?(job_listing).should be_true
      end
    end
    context 'invalid, outside the job listings specified salary range' do
      before :each do
        preference.expected_salary = 100000
        job_listing.salary_range_low = 105000
        job_listing.salary_range_high = 110000
      end
      it 'returns false' do
        preference.valid_salary?(job_listing).should be_false
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
        preference.valid_work_hours?(job_listing).should be_true
      end
    end
    context 'invalid, outside the +/- 5 hours of expected work hours' do
      before :each do
        preference.work_hours = 40
        job_listing.estimated_work_hours = 50
      end
      it 'returns false' do
        preference.valid_work_hours?(job_listing).should be_false
      end
    end
  end
end
