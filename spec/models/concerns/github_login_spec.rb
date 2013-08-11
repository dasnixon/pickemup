require 'spec_helper'

describe GithubLogin do
  let(:generic_auth_github) {
    OpenStruct.new(uid: '123456789', info: auth_info, extra: extra_info_github)
  }
  let(:extra_info_github) do
    OpenStruct.new(raw_info: OpenStruct.new(location: 'San Francisco, CA'))
  end
  let(:auth_info) do
    OpenStruct.new(
      image: 'image.png',
      name:  'Your Name',
      email: 'your@email.com',
      description: 'description'
    )
  end

  describe '#set_user_github_information' do
    let(:user) { build(:user, main_provider: nil, newly_created: nil) }
    let(:github_account) { double(GithubAccount, from_omniauth: true) }
    before :each do
      expect(github_account).to receive(:from_omniauth)
      user.stub(:build_github_account).and_return(github_account)
    end
    it 'sets newly_created virtual attribute to true' do
      user.set_user_github_information(generic_auth_github)
      user.newly_created.should be_true
    end
    it 'sets main_provider to github' do
      user.set_user_github_information(generic_auth_github)
      user.main_provider.should == 'github'
    end
    it 'sets attributes on user object from auth' do
      user.set_user_github_information(generic_auth_github)
      user.name.should == 'Your Name'
      user.email.should == 'your@email.com'
      user.location.should == 'San Francisco, CA'
    end
  end

  describe '#check_and_remove_existing_github' do
    let(:current_user) { create(:user) }
    let(:invalid_user) { create(:user) }
    context 'existing github found' do
      context 'not same user' do
        before :each do
          User.stub(:find_by).and_return(invalid_user)
          expect(invalid_user).to receive(:destroy)
        end
        it 'destroys user record' do
          current_user.check_and_remove_existing_github(invalid_user.github_uid)
        end
      end
      context 'same user' do
        before :each do
          User.stub(:find_by).and_return(current_user)
          expect(invalid_user).to_not receive(:destroy)
        end
        it 'does not destroy user record' do
          current_user.check_and_remove_existing_github(current_user.github_uid)
        end
      end
      context 'user not found' do
        before :each do
          expect(invalid_user).to_not receive(:destroy)
          expect(current_user).to_not receive(:destroy)
        end
        it 'does not destroy user record' do
          current_user.check_and_remove_existing_github('blah')
        end
      end
    end
  end

  describe '#update_github_information' do
    let(:user) { github_account.user }
    let(:github_account) { create(:github_account) }
    before :each do
      user.stub(:github_account).and_return(github_account)
      expect(github_account).to receive(:from_omniauth).with(generic_auth_github)
      expect(UserInformationWorker).to receive(:perform_async).with(user.id)
    end
    it 'updates information from github auth' do
      user.update_github_information(generic_auth_github)
      user.name.should == 'Your Name'
      user.email.should == 'your@email.com'
      user.location.should == 'San Francisco, CA'
    end
  end

  describe '#setup_github_account' do
    let(:user) { create(:user, github_uid: nil) }
    let(:github_account) { double(GithubAccount, from_omniauth: true) }
    before :each do
      user.stub(:build_github_account).and_return(github_account)
      expect(user).to receive(:update).with({github_uid: '123456789'})
      expect(github_account).to receive(:from_omniauth).with(generic_auth_github)
      expect(user).to receive(:check_and_remove_existing_github).with(generic_auth_github.uid)
    end
    it 'performs actions on user that doesnt have a github added yet' do
      user.setup_github_account(generic_auth_github)
    end
  end

  describe '#set_attributes_from_github' do
    let(:user) { create(:user) }
    before :each do
      expect(user).to receive(:save!)
    end
    it 'sets information from github auth' do
      user.set_attributes_from_github(generic_auth_github)
      user.name.should == 'Your Name'
      user.email.should == 'your@email.com'
      user.location.should == 'San Francisco, CA'
    end
  end
end
