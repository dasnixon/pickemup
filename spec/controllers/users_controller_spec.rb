require 'spec_helper'

describe UsersController do
  let(:user) { create(:user) }
  before do
    user_login(user)
  end

  describe '#resume' do
    context 'user not logged in' do
      before :each do
        user_logout
        get(:resume, {id: user.id})
      end
      it { should respond_with(:redirect) }
      it { should redirect_to root_path }
    end
    context 'user logged in not viewing another users resume' do
      let(:other_user) { create(:user) }
      before :each do
        get(:resume, {id: other_user.id})
      end
      it { should respond_with(:redirect) }
      it { should redirect_to root_path }
    end
    context 'valid' do
      context 'user viewing own resume' do
        let(:preference)     { user.preference }
        let(:github_account) { create(:github_account, user: user) }
        let(:repos)          { create_list(:repo, 3, github_account: github_account) }
        let(:orgs)           { create_list(:organization, 3, github_account: github_account) }
        let(:stackexchange)  { create(:stackexchange, user: user) }
        let(:linkedin)       { create(:linkedin, user: user) }
        let(:profile)        { create(:profile, linkedin: linkedin) }
        let(:positions)      { create_list(:position, 3, profile: profile) }
        let(:educations)     { create_list(:education, 3, profile: profile) }
        let(:skills)         { profile.skills }
        before :each do
          user.stub(:github_account).and_return(github_account)
          github_account.stub(:repos).and_return(repos)
          github_account.stub(:organizations).and_return(orgs)
          user.stub(:stackexchange).and_return(stackexchange)
          user.stub(:linkedin).and_return(linkedin)
          linkedin.stub(:profile).and_return(profile)
          profile.stub(:positions).and_return(positions)
          profile.stub(:educations).and_return(educations)
          get(:resume, {id: user.id})
        end
        it { should respond_with(:success) }
        it 'eager loads user information' do
          assigns(:user).should eq user
          assigns(:preference).should eq preference
          assigns(:github_account).should eq github_account
          assigns(:repos).should eq repos
          assigns(:orgs).should eq orgs
          assigns(:stackexchange).should eq stackexchange
          assigns(:linkedin).should eq linkedin
          assigns(:profile).should eq profile
          assigns(:positions).should eq positions
          assigns(:educations).should eq educations
          assigns(:skills).should eq skills
        end
      end
      context 'company viewing user resume' do
        let(:company)        { create(:company) }
        let(:preference)     { user.preference }
        let(:github_account) { create(:github_account, user: user) }
        let(:repos)          { create_list(:repo, 3, github_account: github_account) }
        let(:orgs)           { create_list(:organization, 3, github_account: github_account) }
        let(:stackexchange)  { create(:stackexchange, user: user) }
        let(:linkedin)       { create(:linkedin, user: user) }
        let(:profile)        { create(:profile, linkedin: linkedin) }
        let(:positions)      { create_list(:position, 3, profile: profile) }
        let(:educations)     { create_list(:education, 3, profile: profile) }
        let(:skills)         { profile.skills }
        before :each do
          user_logout
          company_login(company)
          user.stub(:github_account).and_return(github_account)
          github_account.stub(:repos).and_return(repos)
          github_account.stub(:organizations).and_return(orgs)
          user.stub(:stackexchange).and_return(stackexchange)
          user.stub(:linkedin).and_return(linkedin)
          linkedin.stub(:profile).and_return(profile)
          profile.stub(:positions).and_return(positions)
          profile.stub(:educations).and_return(educations)
          get(:resume, {id: user.id})
        end
        it { should respond_with(:success) }
        it 'eager loads user information' do
          assigns(:user).should eq user
          assigns(:preference).should eq preference
          assigns(:github_account).should eq github_account
          assigns(:repos).should eq repos
          assigns(:orgs).should eq orgs
          assigns(:stackexchange).should eq stackexchange
          assigns(:linkedin).should eq linkedin
          assigns(:profile).should eq profile
          assigns(:positions).should eq positions
          assigns(:educations).should eq educations
          assigns(:skills).should eq skills
        end
      end
    end
  end

  describe '#preferences' do
    context 'valid user' do
      before :each do
        get :preferences, {id: user.id}
      end
      it('finds the user') { assigns(:user).should eq user }
      it { should respond_with(:success) }
    end
    context 'user not signed in' do
      before :each do
        user_logout
        get :preferences, {id: user.id}
      end
      it('finds the user') { assigns(:user).should eq user }
      it { should respond_with(:redirect) }
      it { should redirect_to(root_path) }
    end
    context 'user viewing another user\'s preferences page' do
      let(:other_user) { create(:user) }
      before :each do
        user_logout
        user_login(other_user)
        get :preferences, {id: user.id}
      end
      it('finds the user') { assigns(:user).should eq user }
      it { should respond_with(:redirect) }
      it { should redirect_to(root_path) }
    end
  end

  describe '#listings' do
    context 'invalid user' do
      context 'not logged in' do
        before :each do
          user_logout
          get(:listings, {id: user.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
      context 'current user viewing another users' do
        let(:other_user) { create(:user) }
        before :each do
          user_logout
          user_login(other_user)
          get(:listings, {id: user.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
    end
    context 'valid user' do
      let(:job_listing) { create(:job_listing) }
      let(:sentbox) { create_list(:conversation, 3, job_listing_id: job_listing.id) }
      let(:inbox) { create_list(:conversation, 3, job_listing_id: job_listing.id) }
      let(:company) { job_listing.company }
      before :each do
        User.stub(:find).and_return(user)
        JobListing.stub(:find).and_return(job_listing)
        user.stub_chain(:mailbox, :sentbox).and_return(sentbox)
        user.stub_chain(:mailbox, :inbox).and_return(inbox)
        get(:listings, {id: user.id})
      end
      it { should respond_with(:success) }
      it 'sets job_listings from users sentbox' do
        assigns(:job_listings).should eq sentbox.collect { |s| OpenStruct.new(listing: job_listing, company: company, conversation: s) }
      end
      it 'sets user object' do
        assigns(:user).should eq user
      end
    end
  end

  describe '#get_preference' do
    before :each do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end
    context 'invalid user' do
      context 'not logged in' do
        before :each do
          user_logout
          get(:get_preference, {id: user.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
      context 'current user viewing another users' do
        let(:other_user) { create(:user) }
        before :each do
          user_logout
          user_login(other_user)
          get(:get_preference, {id: user.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
    end
    context 'valid user' do
      let(:preference) { create(:preference) }
      before :each do
        preference.stub(:get_preference_defaults).and_return('defaults')
        User.stub(:find).and_return(user)
        user.stub(:preference).and_return(preference)
        get(:get_preference, {id: user.id})
      end
      it { should respond_with(:success) }
      it 'has preference object' do
        response.body.should eq 'defaults'
      end
    end
  end

  describe '#update_preference' do
    before :each do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end
    context 'invalid user' do
      context 'not logged in' do
        before :each do
          user_logout
          put(:update_preference, {id: user.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
      context 'current user viewing another users' do
        let(:other_user) { create(:user) }
        before :each do
          user_logout
          user_login(other_user)
          put(:update_preference, {id: user.id})
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
    end
    context 'valid user' do
      let(:preference) { create(:preference) }
      before :each do
        User.stub(:find).and_return(user)
        user.stub(:preference).and_return(preference)
      end
      context' unable to update' do
        let(:invalid_params) do
          {expected_salary: 'abc'}
        end
        before :each do
          put(:update_preference, {id: user.id, preference: invalid_params })
        end
        it { should respond_with(:bad_request) }
        it 'has errors associated' do
          JSON.parse(response.body)['errors'].should have_key('expected_salary')
        end
      end
      context 'valid update of preferences' do
        let(:valid_params) do
          {expected_salary: 50000}
        end
        before :each do
          put(:update_preference, {id: user.id, preference: valid_params })
        end
        it { should respond_with(204) }
        it 'updates preference' do
          preference.expected_salary.should eq 50000
        end
      end
    end
  end
end
