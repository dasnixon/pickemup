require 'spec_helper'

describe Linkedin do
  it { should belong_to(:user) }
  it { should have_one(:profile) }

  let(:user) { create(:user) }

  let(:extra_info_linkedin) do
    OpenStruct.new(raw_info: OpenStruct.new(industry: 'industry', publicProfileUrl: 'profile_url'))
  end
  let(:auth_info) { OpenStruct.new(description: 'description') }
  let(:linkedin_auth) do
    OpenStruct.new(uid: user.linkedin_uid, info: auth_info, extra: extra_info_linkedin, credentials: OpenStruct.new(token: Faker::Lorem.word))
  end

  describe '#from_omniauth' do
    let(:linkedin) { build(:linkedin, user: user) }
    it 'sets attributes from auth' do
      linkedin.from_omniauth(linkedin_auth)
      linkedin.token.should eq linkedin_auth.credentials.token
      linkedin.headline.should eq 'description'
      linkedin.industry.should eq 'industry'
      linkedin.uid.should eq user.linkedin_uid
      linkedin.profile_url.should eq 'profile_url'
    end
    context 'calls save!' do
      before :each do
        expect(linkedin).to receive(:save!)
      end
      it 'saves the linkedin object' do
        linkedin.from_omniauth(linkedin_auth)
      end
    end
    context 'after_create #grab_user_information' do
      before :each do
        expect(LinkedinWorker).to receive(:perform_async)
      end
      it 'calls grab_user_information after creates linkedin' do
        linkedin.from_omniauth(linkedin_auth)
      end
    end
  end

  describe '#update_linkedin' do
    let(:linkedin) { create(:linkedin) }
    let(:update_information) do
      {'headline' => 'headline', 'industry' => 'industry', 'publicProfileUrl' => 'url'}
    end
    before :each do
      linkedin.stub(:get_profile).and_return(update_information)
      expect(linkedin).to receive(:update_attributes).with({headline: 'headline', industry: 'industry', profile_url: 'url'}) { true }
    end
    context 'user has profile associated with linkedin' do
      let(:profile) { create(:profile, linkedin: linkedin) }
      before :each do
        linkedin.stub(:profile).and_return(profile)
        expect(profile).to receive(:from_omniauth).with(update_information)
      end
      it 'runs expectations' do
        linkedin.update_linkedin
      end
    end
    context 'no profile made yet' do
      before :each do
        linkedin.stub(:profile).and_return(nil)
        Profile.any_instance.should_not_receive(:from_omniauth)
      end
      it 'runs expectations' do
        linkedin.update_linkedin
      end
    end
  end
end
