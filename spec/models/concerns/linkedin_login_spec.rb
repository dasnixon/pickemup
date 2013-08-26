require 'spec_helper'

describe LinkedinLogin do
  let(:generic_auth_linkedin) {
    OpenStruct.new(uid: '123456789', info: auth_info, extra: extra_info_linkedin)
  }
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

  describe '#set_user_linkedin_information' do
    let(:user) { build(:user, main_provider: nil, newly_created: nil) }
    let(:linkedin_account) { double(Linkedin, from_omniauth: true) }
    context 'valid setup' do
      before :each do
        expect(linkedin_account).to receive(:from_omniauth)
        user.stub(:build_linkedin).and_return(linkedin_account)
      end
      it 'sets newly_created virtual attribute to true' do
        user.set_user_linkedin_information(generic_auth_linkedin)
        user.newly_created.should be_true
      end
      it 'sets main_provider to linkedin' do
        user.set_user_linkedin_information(generic_auth_linkedin)
        user.main_provider.should == 'linkedin'
      end
      it 'sets attributes on user object from auth' do
        user.set_user_linkedin_information(generic_auth_linkedin)
        user.name.should == 'Your Name'
        user.email.should == 'your@email.com'
        user.location.should == 'San Francisco, CA'
      end
    end
    context 'unable to set attributes from auth' do
      before :each do
        expect(linkedin_account).to_not receive(:from_omniauth)
        expect(user).to receive(:set_attributes_from_linkedin).and_return(false)
      end
      it 'returns nil' do
        user.set_user_linkedin_information(generic_auth_linkedin).should be_nil
      end
    end
  end

  describe '#check_and_remove_existing_linkedin' do
    let(:current_user) { create(:user) }
    let(:invalid_user) { create(:user) }
    context 'existing linkedin found' do
      context 'not same user' do
        before :each do
          User.stub(:find_by).and_return(invalid_user)
          expect(invalid_user).to receive(:destroy)
        end
        it 'destroys user record' do
          current_user.check_and_remove_existing_linkedin(invalid_user.linkedin_uid)
        end
      end
      context 'same user' do
        before :each do
          User.stub(:find_by).and_return(current_user)
          expect(invalid_user).to_not receive(:destroy)
        end
        it 'does not destroy user record' do
          current_user.check_and_remove_existing_linkedin(current_user.linkedin_uid)
        end
      end
      context 'user not found' do
        before :each do
          expect(invalid_user).to_not receive(:destroy)
          expect(current_user).to_not receive(:destroy)
        end
        it 'does not destroy user record' do
          current_user.check_and_remove_existing_linkedin('blah')
        end
      end
    end
  end

  describe '#update_linkedin_information' do
    let(:user) { linkedin.user }
    let(:linkedin) { create(:linkedin) }
    before :each do
      user.stub(:linkedin).and_return(linkedin)
      expect(linkedin).to receive(:from_omniauth).with(generic_auth_linkedin)
      expect(UserInformationWorker).to receive(:perform_async).with(user.id)
    end
    it 'updates information from linkedin auth' do
      user.update_linkedin_information(generic_auth_linkedin)
      user.name.should == 'Your Name'
      user.email.should == 'your@email.com'
      user.location.should == 'San Francisco, CA'
    end
  end

  describe '#setup_linkedin_account' do
    let(:user) { create(:user, linkedin_uid: nil) }
    let(:linkedin) { double(Linkedin, from_omniauth: true) }
    before :each do
      user.stub(:build_linkedin).and_return(linkedin)
      expect(user).to receive(:update).with({linkedin_uid: '123456789'})
      expect(linkedin).to receive(:from_omniauth).with(generic_auth_linkedin)
      expect(user).to receive(:check_and_remove_existing_linkedin).with(generic_auth_linkedin.uid)
    end
    it 'performs actions on user that doesnt have a linkedin added yet' do
      user.setup_linkedin_account(generic_auth_linkedin)
    end
  end

  describe '#set_attributes_from_linkedin' do
    let(:user) { create(:user) }
    context 'user has not manually setup their profile' do
      before :each do
        expect(user).to receive(:save)
      end
      it 'sets information from linkedin auth' do
        user.set_attributes_from_linkedin(generic_auth_linkedin)
        user.name.should == 'Your Name'
        user.email.should == 'your@email.com'
        user.location.should == 'San Francisco, CA'
      end
      context 'tracking information set' do
        before :each do
          user.track = true
          user.request = 'request'
        end
        it 'calls update_tracked_fields' do
          expect(user).to receive(:update_tracked_fields!).with('request') { true }
          user.set_attributes_from_linkedin(generic_auth_linkedin)
        end
      end
      context 'no tracking information' do
        it 'does not call update_tracked_fields' do
          expect(user).to_not receive(:update_tracked_fields!).with('request') { true }
          user.set_attributes_from_linkedin(generic_auth_linkedin)
        end
      end
    end
    context 'user manually setup profile' do
      before :each do
        user.manually_setup_profile = true
        expect(user).to receive(:save)
      end
      it 'does not set information from linkedin auth' do
        user.set_attributes_from_linkedin(generic_auth_linkedin)
        user.name.should_not == 'Your Name'
        user.email.should_not == 'your@email.com'
        user.location.should_not == 'San Francisco, CA'
        user.name.should == user.name
        user.email.should == user.email
        user.location.should == user.location
      end
      context 'tracking information set' do
        before :each do
          user.track = true
          user.request = 'request'
        end
        it 'calls update_tracked_fields' do
          expect(user).to receive(:update_tracked_fields!).with('request') { true }
          user.set_attributes_from_linkedin(generic_auth_linkedin)
        end
      end
      context 'no tracking information' do
        it 'does not call update_tracked_fields' do
          expect(user).to_not receive(:update_tracked_fields!).with('request') { true }
          user.set_attributes_from_linkedin(generic_auth_linkedin)
        end
      end
    end
  end

  describe '#post_linkedin_setup' do
    context 'linkedin main provider' do
      let(:user) { create(:user, main_provider: 'linkedin') }
      context 'newly created' do
        before :each do
          user.newly_created = true
        end
        it 'stores user profile image' do
          expect(StoreUserProfileImage).to receive(:perform_async)
          user.post_linkedin_setup(generic_auth_linkedin)
        end
        it 'does not call update information worker' do
          expect(UserInformationWorker).to_not receive(:perform_async)
          user.post_linkedin_setup(generic_auth_linkedin)
        end
        it 'does not update linkedin information' do
          expect(user).to_not receive(:update_linkedin_information)
          user.post_linkedin_setup(generic_auth_linkedin)
        end
      end
      context 'not newly created' do
        before :each do
          expect(user).to receive(:update_linkedin_information)
        end
        it 'stores user profile image' do
          expect(StoreUserProfileImage).to receive(:perform_async)
          user.post_linkedin_setup(generic_auth_linkedin)
        end
        it 'does not call update information worker' do
          expect(UserInformationWorker).to_not receive(:perform_async)
          user.post_linkedin_setup(generic_auth_linkedin)
        end
      end
    end
    context 'github main provider' do
      let(:user) { create(:user, main_provider: 'github') }
      context 'newly created' do
        before :each do
          user.newly_created = true
        end
        it 'does nothing' do
          expect(StoreUserProfileImage).to_not receive(:perform_async)
          expect(UserInformationWorker).to_not receive(:perform_async)
          expect(user).to_not receive(:update_linkedin_information)
          user.post_linkedin_setup(auth_info)
        end
      end
      context 'not newly created' do
        before :each do
          expect(UserInformationWorker).to receive(:perform_async)
        end
        it 'does not store user profile image' do
          expect(StoreUserProfileImage).to_not receive(:perform_async)
          user.post_linkedin_setup(generic_auth_linkedin)
        end
        it 'does not update linkedin information' do
          expect(user).to_not receive(:update_linkedin_information)
          user.post_linkedin_setup(generic_auth_linkedin)
        end
      end
    end
  end
end
