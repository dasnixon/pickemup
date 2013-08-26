require 'spec_helper'

describe SessionsController do
  describe '#sign_in' do
    context 'logged in already' do
      context 'user logged in' do
        let(:user) { create(:user) }
        before :each do
          user_login(user)
          get(:sign_in)
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
      context 'company logged in' do
        let(:company) { create(:company) }
        before :each do
          company_login(company)
          get(:sign_in)
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
    end
    context 'no one logged in' do
      before :each do
        get(:sign_in)
      end
      it { should respond_with(:success) }
    end
  end

  describe '#sign_up' do
    context 'logged in already' do
      context 'user logged in' do
        let(:user) { create(:user) }
        before :each do
          user_login(user)
          get(:sign_up)
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
      context 'company logged in' do
        let(:company) { create(:company) }
        before :each do
          company_login(company)
          get(:sign_up)
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
    end
    context 'no one logged in' do
      let(:company) { double(Company) }
      before :each do
        Company.stub(:new).and_return(company)
        get(:sign_up)
      end
      it { should respond_with(:success) }
      it 'has new company object' do
        assigns(:company).should eq company
      end
    end
  end

  describe '#company' do
    context 'logged in already' do
      context 'user logged in' do
        let(:user) { create(:user) }
        before :each do
          user_login(user)
          get(:sign_up)
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
      context 'company logged in' do
        let(:company) { create(:company) }
        before :each do
          company_login(company)
          get(:sign_up)
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
      end
    end
    context 'no one logged in' do
      context 'valid autentication' do
        let(:company) { create(:company) }
        before :each do
          expect(Company).to receive(:authenticate).and_return(company)
          get(:company, {email: company.email, password: 'password'})
        end
        it { should respond_with(:redirect) }
        it('sets session company id') { session[:company_id].should eq company.id }
      end
      context 'invalid authentication' do
        before :each do
          expect(Company).to receive(:authenticate).and_return(nil)
          get(:company, {email: 'test@test.com', password: 'password'})
        end
        it { should respond_with(:success) }
        it { should render_template(:sign_in) }
        it('has nil session company id') { session[:company_id].should be_nil }
      end
    end
  end

  describe '#github' do
    context 'filter' do
      context 'github already synced' do
        let(:user) { create(:user, github_uid: 'synced') }
        before :each do
          user_login(user)
          User.stub(:find).and_return(user)
          get(:github)
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
        it 'has flash notice' do
          flash[:notice].should eq 'Already have your github synced.'
        end
      end
    end
    context 'sync user\'s github' do
      let(:user) { create(:user, github_uid: nil, main_provider: 'linkedin') }
      before :each do
        user_login(user)
        User.stub(:find).and_return(user)
      end
      context 'success setting up github' do
        before :each do
          user.stub(:setup_github_account).and_return(true)
          get(:github)
        end
        it { should respond_with(:redirect) }
        it 'has flash message' do
          flash[:notice].should eq 'Sweet, we got your Github account!'
        end
        it { should redirect_to(root_path) }
      end
      context 'fail setting up github' do
        before :each do
          user.stub(:setup_github_account).and_return(false)
          get(:github)
        end
        it { should respond_with(:redirect) }
        it 'has flash alert' do
          flash[:alert].should eq 'Unable to add your Github, try again later.'
        end
        it { should redirect_to(root_path) }
      end
    end
    context 'not signed in' do
      context 'create new user with github' do
        context 'user successfully created with github' do
          let(:user) { double(User, id: 'ID', present?: true) }
          before :each do
            User.stub(:from_omniauth).and_return(user)
            get(:github)
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(root_path) }
          it 'has flash notice' do
            flash[:notice].should eq 'You are signed in!'
          end
          it('sets session user id') { session[:user_id].should eq user.id }
        end
        context 'user unsuccessfully created with github' do
          let(:user) { double(User, present?: false) }
          before :each do
            User.stub(:from_omniauth).and_return(user)
            get(:github)
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(root_path) }
          it 'has flash alert' do
            flash[:alert].should eq 'Unable to add your Github, try again later. You may have another account in our system with the same email address.'
          end
          it('sets session user id to nil') { session[:user_id].should be_nil }
        end
      end
    end
  end

  describe '#linkedin' do
    context 'filter' do
      context 'linkedin already synced' do
        let(:user) { create(:user, linkedin_uid: 'synced') }
        before :each do
          user_login(user)
          User.stub(:find).and_return(user)
          get(:linkedin)
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
        it 'has flash notice' do
          flash[:notice].should eq 'Already have your linkedin synced.'
        end
      end
    end
    context 'sync user\'s linkedin' do
      let(:user) { create(:user, linkedin_uid: nil, main_provider: 'github') }
      before :each do
        user_login(user)
        User.stub(:find).and_return(user)
      end
      context 'success setting up linkedin' do
        before :each do
          user.stub(:setup_linkedin_account).and_return(true)
          get(:linkedin)
        end
        it { should respond_with(:redirect) }
        it 'has flash message' do
          flash[:notice].should eq 'Sweet, we got your LinkedIn account!'
        end
        it { should redirect_to(root_path) }
      end
      context 'fail setting up linkedin' do
        before :each do
          user.stub(:setup_linkedin_account).and_return(false)
          get(:linkedin)
        end
        it { should respond_with(:redirect) }
        it 'has flash alert' do
          flash[:alert].should eq 'Unable to add your LinkedIn, try again later.'
        end
        it { should redirect_to(root_path) }
      end
    end
    context 'not signed in' do
      context 'create new user with linkedin' do
        context 'user successfully created with linkedin' do
          let(:user) { double(User, id: 'ID', present?: true, update_tracked_fields!: true) }
          before :each do
            User.stub(:from_omniauth).and_return(user)
            get(:linkedin)
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(root_path) }
          it 'has flash notice' do
            flash[:notice].should eq 'You are signed in!'
          end
          it('sets session user id') { session[:user_id].should eq user.id }
        end
        context 'user unsuccessfully created with linkedin' do
          let(:user) { double(User, present?: false) }
          before :each do
            User.stub(:from_omniauth).and_return(user)
            get(:linkedin)
          end
          it { should respond_with(:redirect) }
          it { should redirect_to(root_path) }
          it 'has flash alert' do
            flash[:alert].should eq 'Unable to add your LinkedIn, try again later. You may have another account in our system with the same email address.'
          end
          it('sets session user id to nil') { session[:user_id].should be_nil }
        end
      end
    end
  end

  describe '#stackoverflow' do
    context 'filter' do
      context 'company signed in' do
        let(:company) { create(:company) }
        before :each do
          company_login(company)
          get(:stackoverflow)
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
        it 'has flash alert' do
          flash[:alert].should eq 'Must be logged in!'
        end
      end
      context 'user not signed in' do
        before :each do
          get(:stackoverflow)
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
        it 'has flash alert' do
          flash[:alert].should eq 'Must be logged in!'
        end
      end
      context 'not from stackexchange' do
        let(:user) { create(:user) }
        before :each do
          user_login(user)
          @controller.stub(:from_stackexchange?).and_return(false)
          get(:stackoverflow)
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
        it 'has flash alert' do
          flash[:alert].should eq 'Must be logged in!'
        end
      end
      context 'user already has stackexchange synced' do
        let(:user) { create(:user, stackexchange_synced: true) }
        before :each do
          user_login(user)
          @controller.stub(:from_stackexchange?).and_return(true)
          get(:stackoverflow)
        end
        it { should respond_with(:redirect) }
        it { should redirect_to(root_path) }
        it 'has flash alert' do
          flash[:alert].should eq 'Must be logged in!'
        end
      end
    end
    context 'successfully creates stackexchange' do
      let(:user) { create(:user, stackexchange_synced: false) }
      let(:stackexchange) { double(Stackexchange, from_omniauth: true) }
      before :each do
        user_login(user)
        User.stub(:find).and_return(user)
        user.stub(:build_stackexchange).and_return(stackexchange)
        @controller.stub(:from_stackexchange?).and_return(true)
        get(:stackoverflow)
      end
      it { should respond_with(:redirect) }
      it { should redirect_to(root_path) }
      it 'has flash notice' do
        flash[:notice].should eq 'Successfully linked your Stackoverflow profile!'
      end
    end
    context 'unable to create stackexchange' do
      let(:user) { create(:user, stackexchange_synced: false) }
      let(:stackexchange) { double(Stackexchange, from_omniauth: false) }
      before :each do
        user_login(user)
        User.stub(:find).and_return(user)
        user.stub(:build_stackexchange).and_return(stackexchange)
        @controller.stub(:from_stackexchange?).and_return(true)
        get(:stackoverflow)
      end
      it { should respond_with(:redirect) }
      it { should redirect_to(root_path) }
      it 'has flash alert' do
        flash[:alert].should eq 'Unable to link your Stackoverflow profile!'
      end
    end
  end

  describe '#destroy' do
    context 'company logging out' do
      let(:company) { create(:company) }
      before :each do
        company_login(company)
        get(:destroy)
      end
      it 'clears the session' do
        session[:company_id].should be_nil
      end
      it { should respond_with(:redirect) }
      it { should redirect_to(root_path) }
      it 'has flash notice' do
        flash[:notice].should eq 'Logged out!'
      end
    end
    context 'user logging out' do
      let(:user) { create(:user) }
      before :each do
        user_login(user)
        get(:destroy)
      end
      it 'clears the session' do
        session[:user_id].should be_nil
      end
      it { should respond_with(:redirect) }
      it { should redirect_to(root_path) }
      it 'has flash notice' do
        flash[:notice].should eq 'Logged out!'
      end
    end
  end
end
