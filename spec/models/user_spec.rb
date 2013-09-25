require 'spec_helper'

describe User do
  let(:user) { create(:user) }
  let(:github_account) { create(:github_account) }
  let(:linkedin) { create(:linkedin) }
  before :each do
    user.stub(:github_account).and_return(github_account)
    user.stub(:linkedin).and_return(linkedin)
  end
  let(:generic_auth_github) {
    OpenStruct.new(provider: 'github', uid: '123456789', info: auth_info, extra: extra_info_github)
  }
  let(:generic_auth_linkedin) {
    OpenStruct.new(provider: 'linkedin', uid: '123456789', info: auth_info, extra: extra_info_linkedin)
  }
  let(:extra_info_github) do
    OpenStruct.new(raw_info: OpenStruct.new(location: 'San Francisco, CA'))
  end
  let(:extra_info_linkedin) do
    OpenStruct.new(raw_info: OpenStruct.new(location: OpenStruct.new(name: 'San Francisco, CA')))
  end
  let(:auth_info) do
    OpenStruct.new(
      image: 'image.png',
      name:  'Your Name',
      email: 'your@email.com',
      description: 'description'
    )
  end
  let(:linkedin_auth) do
    OpenStruct.new(provider: 'linkedin', uid: user.linkedin_uid, info: auth_info, extra: extra_info_linkedin, credentials: OpenStruct.new(token: '1234567'))
  end
  let(:github_auth) do
    OpenStruct.new(provider: 'github', uid: user.github_uid, info: auth_info, extra: extra_info_github, credentials: OpenStruct.new(token: '1234567'))
  end

  it { should have_one(:github_account) }
  it { should have_one(:linkedin) }
  it { should have_one(:stackexchange) }

  describe '.from_omniauth' do
    context 'invalid provider' do
      before :each do
        expect(UserInformationWorker).to_not receive(:perform_async)
      end
      it 'returns nil' do
        User.from_omniauth(linkedin_auth, 'bad').should be_nil
      end
    end
    context 'user not found, instantiated' do
      context 'from github' do
        context 'valid create' do
          before :each do
            GithubAccount.any_instance.should_receive(:from_omniauth).with(generic_auth_github).and_return(true)
            expect(StoreUserProfileImage).to receive(:perform_async)
          end
          it 'sets newly_created virtual attribute to true' do
            u = User.from_omniauth(generic_auth_github, :github)
            u.newly_created.should be_true
          end
          it 'sets the main provider to github' do
            u = User.from_omniauth(generic_auth_github, :github)
            u.main_provider.should == 'github'
          end
          it 'sets attributes from auth' do
            u = User.from_omniauth(generic_auth_github, :github)
            u.github_uid.should == '123456789'
            u.linkedin_uid.should be_nil
            u.name.should == 'Your Name'
            u.email.should == 'your@email.com'
          end
          context 'with tracking information' do
            let(:request_info) { OpenStruct.new(remote_ip: '127.0.0.1') }
            it 'sets sign in count' do
              u = User.from_omniauth(generic_auth_github, :github, request_info, true)
              u.sign_in_count.should eq 1
            end
            it 'sets request virtual attribute' do
              u = User.from_omniauth(generic_auth_github, :github, request_info, true)
              u.request.should eq request_info
            end
            it 'sets track virtual attribute' do
              u = User.from_omniauth(generic_auth_github, :github, request_info, true)
              u.track.should be_true
            end
          end
        end
        context 'invalid create' do
          before :each do
            User.any_instance.stub(:save).and_return(false)
          end
          it('returns nil') { User.from_omniauth(generic_auth_github, :github).should be_nil }
        end
      end
      context 'from linkedin' do
        context 'valid create' do
          before :each do
            Linkedin.any_instance.stub(:from_omniauth).with(generic_auth_linkedin).and_return(true)
            expect(StoreUserProfileImage).to receive(:perform_async)
          end
          it 'sets newly_created virtual attribute to true' do
            u = User.from_omniauth(generic_auth_linkedin, :linkedin)
            u.newly_created.should be_true
          end
          it 'sets the main provider to github' do
            u = User.from_omniauth(generic_auth_linkedin, :linkedin)
            u.main_provider.should == 'linkedin'
          end
          it 'sets attributes from auth' do
            u = User.from_omniauth(generic_auth_linkedin, :linkedin)
            u.github_uid.should be_nil
            u.linkedin_uid.should == '123456789'
            u.name.should == 'Your Name'
            u.email.should == 'your@email.com'
          end
          context 'with tracking information' do
            let(:request_info) { OpenStruct.new(remote_ip: '127.0.0.1') }
            it 'sets sign in count' do
              u = User.from_omniauth(generic_auth_linkedin, :linkedin, request_info, true)
              u.sign_in_count.should eq 1
            end
            it 'sets request virtual attribute' do
              u = User.from_omniauth(generic_auth_linkedin, :linkedin, request_info, true)
              u.request.should eq request_info
            end
            it 'sets track virtual attribute' do
              u = User.from_omniauth(generic_auth_linkedin, :linkedin, request_info, true)
              u.track.should be_true
            end
          end
        end
        context 'invalid create' do
          before :each do
            User.any_instance.stub(:save).and_return(false)
          end
          it('returns nil') { User.from_omniauth(generic_auth_linkedin, :linkedin).should be_nil }
        end
      end
    end
    context 'user found on lookup' do
      before :each do
        User.stub_chain(:where, :first_or_initialize).and_return(user)
      end
      context 'from github provider' do
        context 'main provider is github' do
          before :each do
            expect(user).to receive(:update_github_account_information).with(github_auth).and_return(true)
            expect(UserInformationWorker).to_not receive(:perform_async)
            expect(StoreUserProfileImage).to receive(:perform_async)
          end
          it 'returns the user object' do
            User.from_omniauth(github_auth, :github).should == user
          end
          it 'newly created virtual attribute is nil on user' do
            user = User.from_omniauth(github_auth, :github)
            user.newly_created.should be_nil
          end
        end
        context 'main provider is linkedin' do
          let(:github_account) { create(:github_account) }
          before :each do
            user.main_provider = 'linkedin'
            expect(user).to_not receive(:update_github_account_information)
            expect(user).to receive(:github_account).and_return(github_account)
            expect(github_account).to receive(:update) { true }
            expect(UserInformationWorker).to receive(:perform_async).with(user.id)
            expect(StoreUserProfileImage).to_not receive(:perform_async)
          end
          it 'returns the user object' do
            User.from_omniauth(github_auth, :github).should == user
          end
          it 'newly created virtual attribute is nil on user' do
            user = User.from_omniauth(github_auth, :github)
            user.newly_created.should be_nil
          end
        end
      end
      context 'from linkedin provider' do
        let(:linkedin) { create(:linkedin) }
        context 'main provider is github' do
          before :each do
            expect(user).to_not receive(:update_linkedin_information)
            expect(user).to receive(:linkedin).and_return(linkedin)
            expect(linkedin).to receive(:update) { true }
            expect(UserInformationWorker).to receive(:perform_async).with(user.id)
            expect(StoreUserProfileImage).to_not receive(:perform_async)
          end
          it 'returns the user object' do
            User.from_omniauth(linkedin_auth, :linkedin).should == user
          end
          it 'newly created virtual attribute is nil on user' do
            user = User.from_omniauth(linkedin_auth, :linkedin)
            user.newly_created.should be_nil
          end
        end
        context 'main provider is linkedin' do
          before :each do
            user.main_provider = 'linkedin'
            expect(user).to receive(:update_linkedin_information).with(linkedin_auth) { true }
            expect(UserInformationWorker).to_not receive(:perform_async).with(user.id)
            expect(StoreUserProfileImage).to receive(:perform_async)
          end
          it 'returns the user object' do
            User.from_omniauth(linkedin_auth, :linkedin).should == user
          end
          it 'newly created virtual attribute is nil on user' do
            user = User.from_omniauth(linkedin_auth, :linkedin)
            user.newly_created.should be_nil
          end
        end
      end
    end
  end

  describe '#mailboxer_email' do
    it('returns user email') { user.mailboxer_email('test').should == user.email }
  end

  describe '#mailboxer_name' do
    it('returns user name') { user.mailboxer_name.should == user.name }
  end

  describe '#set_stackexchange_synced' do
    before :each do
      expect(user).to receive(:save!) { true }
    end
    it 'sets stackexchange_synced to true' do
      user.set_stackexchange_synced
      user.stackexchange_synced.should be_true
    end
  end

  describe '#set_stackexchange_unsynced' do
    before :each do
      expect(user).to receive(:save!) { true }
    end
    it 'sets stackexchange_synced to true' do
      user.set_stackexchange_unsynced
      user.stackexchange_synced.should be_false
    end
  end

  describe '#update_resume' do
    let(:github_account) { double(GithubAccount, setup_information: true) }
    context 'github_uid present' do
      before :each do
        user.stub(:github_account).and_return(github_account)
        user.linkedin_uid = nil
      end
      it 'calls #setup_information' do
        expect(github_account).to receive(:setup_information).and_return(true)
        user.update_resume
      end
    end
    context 'linkedin_uid present' do
      let(:linkedin) { double(Linkedin, update_linkedin: true) }
      before :each do
        user.stub(:linkedin).and_return(linkedin)
        user.github_uid = nil
      end
      it 'calls #update_linkedin' do
        expect(linkedin).to receive(:update_linkedin)
        user.update_resume
      end
    end
    context 'stackexchange synced' do
      let(:github_account) { double(GithubAccount, setup_information: true) }
      let(:stackexchange)  { double(Stackexchange, update_stackexchange: true) }
      before :each do
        user.linkedin_uid = nil
        user.github_uid = nil
        user.stackexchange_synced = true
        user.stub(:stackexchange).and_return(stackexchange)
      end
      it 'calls #update_stackexchange' do
        expect(stackexchange).to receive(:update_stackexchange)
        user.update_resume
      end
    end
  end
end
