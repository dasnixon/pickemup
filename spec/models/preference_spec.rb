require 'spec_helper'

describe Preference do
  it { should belong_to(:user) }

  def with_attrs(attrs={})
    build(:preference, attrs)
  end

  describe 'validations' do
    context 'expected_salary' do
      context 'inclusion' do
        subject(:preference) { with_attrs(expected_salary: 9999999999999999) }
        it { should have(1).error_on(:expected_salary) }
      end
      context 'numericality' do
        subject(:preference) { with_attrs(expected_salary: 'abc') }
        it { should have(1).error_on(:expected_salary) }
      end
    end
    context 'work_hours' do
      context 'inclusion' do
        subject(:preference) { with_attrs(work_hours: 2000) }
        it { should have(1).error_on(:work_hours) }
      end
      context 'numericality' do
        subject(:preference) { with_attrs(work_hours: 'abc') }
        it { should have(1).error_on(:work_hours) }
      end
    end
    context 'potential_availability' do
      context 'inclusion' do
        subject(:preference) { with_attrs(potential_availability: 200) }
        it { should have(1).error_on(:potential_availability) }
      end
      context 'numericality' do
        subject(:preference) { with_attrs(potential_availability: 'abc') }
        it { should have(1).error_on(:potential_availability) }
      end
    end
  end

  let(:user_preference) { create(:preference) }

  describe '#get_attr_values' do
    context 'defaults only' do
      let(:preference) { create(:preference, settings: []) }
      let(:expected) do
        Preference::SETTINGS.collect { |p| { name: p, checked: false } }
      end
      it 'returns default constant values with false checked values' do
        preference.get_attr_values('settings').should eq expected
      end
    end
    context 'data already set for attribute' do
      let(:preference) { create(:preference, settings: ['Urban', 'Office Park']) }
      let(:expected) do
        [{ name: 'Urban', checked: true }, { name: 'Rural', checked: false }, {name: 'Office Park', checked: true}]
      end
      it 'returns default constant values with false checked values' do
        preference.get_attr_values('settings').should =~ expected
      end
    end
  end

  describe '#attribute_default_values' do
    context 'skills attribute' do
      context 'user has linkedin synced' do
        let(:preference) { create(:preference, user: user) }
        let(:user) { create(:user, linkedin_uid: generate(:guid)) }
        let(:linkedin) { double(Linkedin, profile: profile) }
        let(:profile) { double(Profile, skills: ['Ruby', 'Python']) }
        before :each do
          preference.stub(:user).and_return(user)
          user.stub(:linkedin).and_return(linkedin)
        end
        it 'returns the skills from linkedin profile' do
          preference.attribute_default_values('skills').should =~ ['Ruby', 'Python']
        end
      end
      context 'user linkedin not synced' do
        let(:preference) { create(:preference, user: user) }
        let(:user) { create(:user, linkedin_uid: nil) }
        before :each do
          preference.stub(:user).and_return(user)
        end
        it 'returns the skills from linkedin profile' do
          preference.attribute_default_values('skills').should be_blank
        end
      end
    end
    context 'all other attributes, not skills' do
      let(:preference) { create(:preference) }
      it 'returns the constant for the attribute' do
        preference.attribute_default_values('positions').should eq Preference::POSITIONS
      end
    end
  end

  describe '.cleanup_invalid_data' do
    context 'skips' do
      let(:parameters) do
        {'blah' => 'fake'}
      end
      it 'does not have specific key' do
        Preference.cleanup_invalid_data(parameters).should eq parameters
      end
    end
    context 'invalid data' do
      context 'attribute value not array' do
        let(:parameters) do
          {'skills' => 'fake'}
        end
        it 'removes the attribute from the parameter' do
          Preference.cleanup_invalid_data(parameters).should_not have_key('skills')
        end
      end
    end
    context 'valid data' do
      context 'rejected' do
        let(:parameters) do
          {'skills' => [{'checked' => false, 'name' => Faker::Name.name},
                        {'checked' => false, 'name' => Faker::Name.name}]}
        end
        it 'sets attribute to empty array since rejected' do
          Preference.cleanup_invalid_data(parameters).should eq({'skills' => []})
        end
      end
      context 'accepted' do
        let(:parameters) do
          {'skills' => [{'checked' => true, 'name' => 'Ruby'},
                        {'checked' => true, 'name' => 'Python'}]}
        end
        it 'sets attribute to empty array since rejected' do
          Preference.cleanup_invalid_data(parameters).should eq({'skills' => ['Ruby', 'Python']})
        end
      end
    end
  end

  describe '.reject_attrs' do
    context 'rejected' do
      context 'does not have valid keys (checked, name)' do
        let(:param) do
          [{'test' => 'this'}]
        end
        it 'returns blank array' do
          Preference.reject_attrs(param).should eq []
        end
      end
      context 'has more than 2 keys' do
        let(:param) do
          [{'checked' => true, 'name' => Faker::Name.name, 'test' => 'this'}]
        end
        it 'returns blank array' do
          Preference.reject_attrs(param).should eq []
        end
      end
      context 'checked is not a boolean' do
        let(:param) do
          [{'checked' => 'haha', 'name' => Faker::Name.name}]
        end
        it 'returns blank array' do
          Preference.reject_attrs(param).should eq []
        end
      end
      context 'attribute is not checked, set to true' do
        let(:param) do
          [{'checked' => false, 'name' => Faker::Name.name}]
        end
        it 'returns blank array' do
          Preference.reject_attrs(param).should eq []
        end
      end
    end
    context 'accepted' do
      let(:param) do
        [{'checked' => true, 'name' => Faker::Name.name}]
      end
      it 'does not reject' do
        Preference.reject_attrs(param).should eq param
      end
    end
  end
end
