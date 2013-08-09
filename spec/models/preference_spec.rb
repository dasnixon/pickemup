require 'spec_helper'

describe Preference do
  it { should belong_to(:user) }

  def build_with_attrs(attrs={})
    build(:preference, attrs)
  end

  describe 'validations' do
    context 'expected_salary' do
      context 'inclusion' do
        subject(:preference) { build_with_attrs(expected_salary: 9999999999999999) }
        it { should have(1).error_on(:expected_salary) }
      end
      context 'numericality' do
        subject(:preference) { build_with_attrs(expected_salary: 'abc') }
        it { should have(1).error_on(:expected_salary) }
      end
    end
    context 'work_hours' do
      context 'inclusion' do
        subject(:preference) { build_with_attrs(work_hours: 2000) }
        it { should have(1).error_on(:work_hours) }
      end
      context 'numericality' do
        subject(:preference) { build_with_attrs(work_hours: 'abc') }
        it { should have(1).error_on(:work_hours) }
      end
    end
    context 'potential_availability' do
      context 'inclusion' do
        subject(:preference) { build_with_attrs(potential_availability: 200) }
        it { should have(1).error_on(:potential_availability) }
      end
      context 'numericality' do
        subject(:preference) { build_with_attrs(potential_availability: 'abc') }
        it { should have(1).error_on(:potential_availability) }
      end
    end
  end

  let(:user_preference) { create(:preference) }
  let(:default_preference_data) do
    { healthcare: user_preference.healthcare, dentalcare: user_preference.dentalcare, visioncare: user_preference.visioncare,
      life_insurance: user_preference.life_insurance, paid_vacation: user_preference.paid_vacation, equity: user_preference.equity,
      bonuses: user_preference.bonuses, retirement: user_preference.retirement, fulltime: user_preference.fulltime, remote: user_preference.remote,
      open_source: user_preference.open_source, expected_salary: user_preference.expected_salary, us_citizen: user_preference.us_citizen,
      potential_availability: user_preference.potential_availability, work_hours: user_preference.work_hours }
  end

  describe '#default_hash' do
    it('returns default attributes from a preference object') { user_preference.default_hash.should == default_preference_data }
  end
end
