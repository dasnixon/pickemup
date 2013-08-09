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
    end
    context 'user logged in not viewing another users resume' do
      let(:other_user) { create(:user) }
      before :each do
        get(:resume, {id: other_user.id})
      end
      it { should respond_with(:redirect) }
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
end
