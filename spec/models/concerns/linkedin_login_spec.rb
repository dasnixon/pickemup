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

  describe '#check_and_remove_existing_linkedin' do
    let(:current_user) { create(:user) }
    let(:invalid_user) { create(:user) }
    context 'existing linkedin found' do
      context 'not same user' do
        before :each do
          User.stub(:where).and_return([invalid_user])
          expect(invalid_user).to receive(:destroy)
        end
        it 'destroys user record' do
          current_user.check_and_remove_existing_linkedin(invalid_user.linkedin_uid)
        end
      end
      context 'same user' do
        before :each do
          User.stub(:where).and_return([current_user])
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
    before :each do
      expect(user).to receive(:save!)
    end
    it 'sets information from linkedin auth' do
      user.set_attributes_from_linkedin(generic_auth_linkedin)
      user.name.should == 'Your Name'
      user.email.should == 'your@email.com'
      user.location.should == 'San Francisco, CA'
    end
  end
end
