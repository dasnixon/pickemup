require 'spec_helper'

describe JobListing do
  def with_attrs(attrs = {})
    build(:job_listing, attrs)
  end

  it { should belong_to(:company) }
  it { should have_many(:conversations) }

  describe 'validations' do
    context 'job description' do
      context 'presence' do
        subject(:job_listing) { with_attrs({job_description: ''}) }
        it { should have(1).errors_on(:job_description) }
      end
    end
    context 'salary range' do
      context 'range high presence' do
        subject(:job_listing) { with_attrs({salary_range_low: 100000, salary_range_high: nil}) }
        it { should have(2).errors_on(:salary_range_high) }
      end
      context 'range low presence' do
        subject(:job_listing) { with_attrs({salary_range_low: nil, salary_range_high: 90000}) }
        it { should have(2).errors_on(:salary_range_low) }
      end
      context 'range high numericality' do
        subject(:job_listing) { with_attrs({salary_range_low: 100000, salary_range_high: 'abc'}) }
        it { should have(1).errors_on(:salary_range_high) }
      end
      context 'range low numericality' do
        subject(:job_listing) { with_attrs({salary_range_low: 'abc', salary_range_high: 90000}) }
        it { should have(1).errors_on(:salary_range_low) }
      end
      context 'range from low to high' do
        subject(:job_listing) { with_attrs({salary_range_low: 1000000, salary_range_high: 90000}) }
        it { should have(1).errors_on(:salary_range) }
      end
    end
  end

  describe '#get_attr_values' do
    context 'defaults only' do
      let(:job_listing) { create(:job_listing, special_characteristics: []) }
      let(:expected) do
        JobListing::SPECIAL_CHARACTERISTICS.collect { |p| { name: p, checked: false } }
      end
      it 'returns default constant values with false checked values' do
        job_listing.get_attr_values('special_characteristics').should eq expected
      end
    end
    context 'data already set for attribute' do
      let(:job_listing) { create(:job_listing, special_characteristics: ['Entrepreneur', 'Blogger']) }
      let(:expected) do
        [{ name: 'Entrepreneur', checked: true }, { name: 'Blogger', checked: true }, {name: 'Open Source Committer', checked: false}]
      end
      it 'returns default constant values with false checked values' do
        job_listing.get_attr_values('special_characteristics').should =~ expected
      end
    end
  end

  describe '#salary_range' do
    let(:job_listing) { create(:job_listing) }
    it 'gives range of salary from low to high' do
      job_listing.salary_range.should eq job_listing.salary_range_low..job_listing.salary_range_high
    end
  end

  describe '#attribute_default_values' do
    let(:job_listing) { create(:job_listing) }
    it 'returns the constant for the attribute' do
      job_listing.attribute_default_values('practices').should eq JobListing::PRACTICES
    end
  end

  describe '.cleanup_invalid_data' do
    context 'skips' do
      let(:parameters) do
        {'blah' => 'fake'}
      end
      it 'does not have specific key' do
        JobListing.cleanup_invalid_data(parameters).should eq parameters
      end
    end
    context 'invalid data' do
      context 'attribute value not array' do
        let(:parameters) do
          {'practices' => 'fake'}
        end
        it 'removes the attribute from the parameter' do
          JobListing.cleanup_invalid_data(parameters).should_not have_key('practices')
        end
      end
    end
    context 'valid data' do
      context 'rejected' do
        let(:parameters) do
          {'practices' => [{'checked' => false, 'name' => Faker::Name.name},
                        {'checked' => false, 'name' => Faker::Name.name}]}
        end
        it 'sets attribute to empty array since rejected' do
          JobListing.cleanup_invalid_data(parameters).should eq({'practices' => []})
        end
      end
      context 'accepted' do
        let(:parameters) do
          {'practices' => [{'checked' => true, 'name' => 'Scrum'},
                        {'checked' => true, 'name' => 'Agile Development'}]}
        end
        it 'sets attribute to empty array since rejected' do
          JobListing.cleanup_invalid_data(parameters).should eq({'practices' => ['Scrum', 'Agile Development']})
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
          JobListing.reject_attrs(param).should eq []
        end
      end
      context 'has more than 2 keys' do
        let(:param) do
          [{'checked' => true, 'name' => Faker::Name.name, 'test' => 'this'}]
        end
        it 'returns blank array' do
          JobListing.reject_attrs(param).should eq []
        end
      end
      context 'checked is not a boolean' do
        let(:param) do
          [{'checked' => 'haha', 'name' => Faker::Name.name}]
        end
        it 'returns blank array' do
          JobListing.reject_attrs(param).should eq []
        end
      end
      context 'attribute is not checked, set to true' do
        let(:param) do
          [{'checked' => false, 'name' => Faker::Name.name}]
        end
        it 'returns blank array' do
          JobListing.reject_attrs(param).should eq []
        end
      end
    end
    context 'accepted' do
      let(:param) do
        [{'checked' => true, 'name' => Faker::Name.name}]
      end
      it 'does not reject' do
        JobListing.reject_attrs(param).should eq param
      end
    end
  end

  describe '#toggle_active' do
    context 'deactivate job listing' do
      let(:job_listing) { create(:job_listing, active: true) }
      before :each do
        job_listing.toggle_active
      end
      it('is deactivated') { job_listing.should_not be_active }
    end
    context 'activate job listing' do
      let(:job_listing) { create(:job_listing, active: false) }
      before :each do
        job_listing.toggle_active
      end
      it('is activated') { job_listing.should be_active }
    end
  end
end
