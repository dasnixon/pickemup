require 'spec_helper'

describe Company do
  def with_attrs(attrs = {})
    build(:company, attrs)
  end

  let(:company) { create(:company) }

  it { should have_one(:subscription) }
  it { should have_many(:job_listings) }
  it { should have_many(:tech_stacks) }

  describe 'validations' do
    context 'defaults' do
      let(:subject) { with_attrs }
      it { should have(:no).errors }
    end

    context 'email' do
      context 'presence' do
        let(:subject) { with_attrs({email: nil}) }
        it { should have(2).errors_on(:email) }
      end
      context 'uniqueness' do
        let(:subject) { with_attrs({email: company.email}) }
        it { should have(1).errors_on(:email) }
      end
      context 'format' do
        let(:subject) { with_attrs({email: 'blah'}) }
        it { should have(1).errors_on(:email) }
      end
      context 'valid' do
        let(:subject) { with_attrs({email: Faker::Internet.email}) }
        it { should have(0).errors_on(:email) }
      end
    end

    context 'name' do
      context 'presence' do
        let(:subject) { with_attrs({name: nil}) }
        it { should have(1).errors_on(:name) }
      end
      context 'uniqueness' do
        let(:subject) { with_attrs({name: company.name}) }
        it { should have(1).errors_on(:name) }
      end
      context 'valid' do
        let(:subject) { with_attrs({name: 'Pickemup'}) }
        it { should have(0).errors_on(:name) }
      end
    end

    context 'password' do
      context 'presence' do
        let(:subject) { with_attrs({password: ''}) }
        it { should have(2).errors_on(:password) }
      end
      context 'length' do
        let(:subject) { with_attrs({password: 'pass'}) }
        it { should have(1).errors_on(:password) }
      end
    end

    context 'size_definition' do
      context 'inclusion' do
        let(:subject) { with_attrs({size_definition: 'Blah'}) }
        it { should have(1).errors_on(:size_definition) }
      end
    end
  end

  describe '#calculate_score' do
    context 'num_employees present' do
      let(:company) { create(:company, num_employees: '10') }
      it 'returns integer value of num_employees' do
        company.calculate_score.should eq 10
      end
    end
    context 'num_employees not present' do
      let(:company) { create(:company, num_employees: nil) }
      it 'returns default of 1' do
        company.calculate_score.should eq 1
      end
    end
  end

  describe '#get_logo' do
    context 'company has logo present' do
      before :each do
        company.logo = Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'vim_recruit.png'))
      end
      it('returns company logo') { company.get_logo.should eq company.logo.preview }
    end
    context 'company has no logo, default used' do
      it 'returns default logo' do
        company.logo = nil
        company.get_logo.should eq 'default_logo.png'
      end
    end
  end

  describe '#set_verified' do
    it 'sets verified to true' do
      company.set_verified
      company.verified.should be_true
    end
  end

  describe '#clean_error_messages' do
    context '1 error' do
      before :each do
        company.name = ''
        company.save
      end
      it 'returns single clean error statement' do
        company.clean_error_messages.should eq 'Name can\'t be blank'
      end
    end
    context '2 same errors' do
      before :each do
        company.email = ''
        company.save
      end
      it 'returns error statement connected with and' do
        company.clean_error_messages.should eq 'Email can\'t be blank and is invalid'
      end
    end
    context '2 different errors' do
      before :each do
        company.name = ''
        company.email = ''
        company.save
      end
      it 'returns error statement connected , then ends with and' do
        company.clean_error_messages.should include 'Email can\'t be blank and is invalid'
        company.clean_error_messages.should include 'Name can\'t be blank'
      end
    end
  end

  context '#get_crunchbase_info' do
    let(:crunchbase_api) do
      OpenStruct.new(homepage_url: Faker::Internet.http_url,
                     number_of_employees: 10,
                     ipo: true,
                     overview: Faker::Lorem.sentences.join(' '),
                     founded: Date.today,
                     total_money_raised: '$5000000',
                     tags: 'this is a tag',
                     image: image,
                     competitions: [{'competitor' => {'name' => Faker::Name.name }}])
    end

    let(:image) do
      {"available_sizes"=>[[[150, 150], "assets/images/resized/0000/2755/2755v33-max-150x150.png"], [[250, 250], "assets/images/resized/0000/2755/2755v33-max-250x250.png"], [[300, 300], "assets/images/resized/0000/2755/2755v33-max-450x450.png"]], "attribution"=>nil}
    end

    context 'valid request' do
      before :each do
        Crunchbase::Company.stub(:get).and_return(crunchbase_api)
      end
      it 'sets valid information on company from crunchbase api' do
        company.get_crunchbase_info
        company.website.should eq crunchbase_api.homepage_url
        company.public.should be_true
        company.num_employees.should eq crunchbase_api.number_of_employees
        company.competitors.length.should eq 1
      end
    end
    context 'invalid request' do
      before :each do
        expect(Crunchbase::Company).to receive(:get).and_raise(Crunchbase::CrunchException)
        expect(Rails.logger).to receive(:error)
        expect(company).to receive(:save)
      end
      it 'makes the expectations' do
        company.get_crunchbase_info
      end
    end
  end

  describe '.authenticate' do
    let(:request) { OpenStruct.new(remote_ip: '127.0.0.1') }
    context 'company found' do
      let(:found_company) { double(Company, password_hash: 'password_hash', password_salt: 'salt', save_with_tracking_info: true) }
      before :each do
        Company.stub(:find_by).and_return(found_company)
        BCrypt::Engine.stub(:hash_secret).and_return(found_company.password_hash)
      end
      it 'returns company' do
        Company.authenticate('email@email.com', 'password', request).should eq found_company
      end
    end
    context 'invalid authentication' do
      context 'company not found' do
        let(:found_company) { double(Company, password_hash: 'password_hash', password_salt: 'salt') }
        before :each do
          Company.stub(:find_by).and_return(nil)
        end
        it 'returns company' do
          Company.authenticate('email@email.com', 'password', request).should be_nil
        end
      end
      context 'invalid password' do
        let(:found_company) { double(Company, password_hash: 'password_hash', password_salt: 'salt') }
        before :each do
          Company.stub(:find_by).and_return(found_company)
          BCrypt::Engine.stub(:hash_secret).and_return('blah')
        end
        it 'returns company' do
          Company.authenticate('email@email.com', 'password', request).should be_nil
        end
      end
    end
  end

  describe '#collected_tech_stacks' do
    let(:tech_stacks) { create_list(:tech_stack, 2, company: company) }
    let(:expected) do
      tech_stacks.collect { |s| {name: s.name, id: s.id}}
    end
    before :each do
      company.stub(:tech_stacks).and_return(tech_stacks)
    end
    it 'gets a collection of tech stack information' do
      company.collected_tech_stacks.should =~ expected
    end
  end
end
