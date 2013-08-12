require 'spec_helper'

describe CompaniesController do
  describe '#create' do
    let(:company_params) do
      {company:
        {email: Faker::Internet.email, name: Faker::Name.name,
         password: 'password', description: Faker::Lorem.sentences.join(' '),
         website: Faker::Internet.http_url}}
    end
    context 'invalid company' do
      before :each do
        Company.any_instance.stub(:save).and_return(false)
        post(:create, company_params)
      end
      it { should render_template('sessions/sign_up') }
      it { should respond_with(:success) }
    end
    context 'valid company' do
      let(:notifier) { double(Notifier, deliver: true) }
      before :each do
        expect(Notifier).to receive(:new_company_confirmation).and_return(notifier)
        post(:create, company_params)
      end
      it { should respond_with(:redirect) }
    end
  end

  describe '#show' do
    let(:company) { create(:company) }
    let(:job_listings) { create_list(:job_listing, 3, company: company) }
    before :each do
      expect(Company).to receive(:find).and_return(company)
      company.stub(:job_listings).and_return(job_listings)
      get(:show, {id: company.id})
    end
    it 'finds the company' do
      assigns(:company).should eq company
    end
    it 'looks up company\'s job listings' do
      assigns(:job_listings).should eq job_listings
    end
  end

  describe '#edit' do
    let(:user) { create(:user) }
    let(:company) { create(:company) }
    let(:subscription) { create(:subscription, company: company) }
    context 'invalid permissions' do
      context 'user signed in' do
        before :each do
          user_login(user)
          get(:edit, {id: company.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
      context 'company not signed in' do
        before :each do
          get(:edit, {id: company.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
      context 'current company not company found' do
        let(:other_company) { create(:company) }
        before :each do
          company_login(company)
          get(:edit, {id: other_company.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
    end
    context 'valid permissions' do
      before :each do
        company_login(company)
        company.stub(:subscription).and_return(subscription)
        get(:edit, {id: company.id})
      end
      it { should respond_with(:success) }
      it('sets company variable') { assigns(:company).should eq company }
      it('sets subscription variable') { assigns(:subscription).should eq subscription }
    end
  end

  describe '#update' do
    let(:company_params) do
      {company:
        {email: Faker::Internet.email, name: Faker::Name.name,
         password: 'password', description: Faker::Lorem.sentences.join(' '),
         website: Faker::Internet.http_url}}
    end
    let(:user) { create(:user) }
    let(:company) { create(:company) }
    let(:subscription) { create(:subscription, company: company) }
    context 'invalid permissions' do
      context 'user signed in' do
        before :each do
          user_login(user)
          put(:update, {id: company.id}.merge(company_params))
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
      context 'company not signed in' do
        before :each do
          put(:update, {id: company.id}.merge(company_params))
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
      context 'current company not company found' do
        let(:other_company) { create(:company) }
        before :each do
          company_login(company)
          put(:update, {id: other_company.id}.merge(company_params))
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
    end
    context 'valid permissions' do
      context 'invalid parameters' do
        before :each do
          company_login(company)
          put(:update, {id: company.id}.merge({company: {name: ''}}))
        end
        it { should render_template :edit }
        it { should respond_with(:success) }
        it 'has flash error message' do
          flash[:error].should eq 'Unable to update your company information'
        end
      end
      context 'valid parameters' do
        before :each do
          company_login(company)
          put(:update, {id: company.id}.merge({company: {name: 'New Name'}}))
        end
        it { should respond_with(:redirect) }
        it 'has flash notice message' do
          flash[:notice].should eq 'Info updated!'
        end
      end
    end
  end

  describe '#validate_company' do
    let(:company) { create(:company) }
    context 'invalid permissions' do
      context 'company not logged in' do
        before :each do
          get(:validate_company, {email: company.email})
        end
        it { should redirect_to(root_path) }
        it { should respond_with(:redirect) }
        it 'sets company to verified' do
          company.verified.should be_false
        end
      end
      context 'company logged in not company verifying' do
        let(:other_company) { create(:company) }
        before :each do
          company_login(other_company)
          get(:validate_company, {email: company.email})
        end
        it { should redirect_to(root_path) }
        it { should respond_with(:redirect) }
        it 'sets company to verified' do
          company.verified.should be_false
        end
      end
    end
    context 'valid permissions' do
      before :each do
        company_login(company)
        Company.stub(:find_by).and_return(company)
        get(:validate_company, {email: company.email})
      end
      it { should redirect_to(root_path) }
      it { should respond_with(:redirect) }
      it 'sets company to verified' do
        company.verified.should be_true
      end
    end
  end
end
