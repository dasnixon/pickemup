require 'spec_helper'

describe Stackexchange do
  it { should belong_to(:user) }

  let(:stackexchange) { create(:stackexchange, user: user) }
  let(:user) { create(:user) }

  let(:stackexchange_auth) do
    OpenStruct.new(
      uid: generate(:guid),
      info: stackexchange_info,
      extra: stackexchange_raw,
      credentials: OpenStruct.new(token: generate(:guid))
    )
  end

  let(:stackexchange_raw) do
    OpenStruct.new(raw_info: raw_information)
  end

  let(:raw_information) do
    OpenStruct.new(
      repuation: 50,
      age: 24,
      badge_counts: {'gold' => 1, 'silver' => 2, 'bronze' => 10},
      display_name: Faker::Name.name,
      user_id: generate(:guid)
    )
  end

  let(:stackexchange_info) do
    OpenStruct.new(
      nickname: Faker::Lorem.word,
      urls: stackoverflow_url
    )
  end

  let(:stackoverflow_url) { OpenStruct.new(stackoverflow: Faker::Internet.http_url) }

  let(:serel_api) do
    OpenStruct.new(
      display_name: Faker::Name.name,
      repuation: 899,
      age: 25,
      badge_counts: {'gold' => 2, 'silver' => 4, 'bronze' => 20}
    )
  end

  describe '#from_omniauth' do
    before :each do
      expect(user).to receive(:set_stackexchange_synced)
    end
    let(:built_stackexchange) { build(:stackexchange, user: user) }
    it 'updates information from stackexchange auth' do
      built_stackexchange.from_omniauth(stackexchange_auth)
      built_stackexchange.uid.should eq stackexchange_auth.uid
      built_stackexchange.token.should eq stackexchange_auth.credentials.token
    end
    it 'creates a new record' do
      expect { built_stackexchange.from_omniauth(stackexchange_auth) }.to change(Stackexchange, :count).by(1)
    end
  end

  describe '#update_stackexchange' do
    before :each do
      expect(stackexchange).to receive(:get_stackexchange_user) { serel_api }
      expect(user).to_not receive(:set_stackexchange_synced)
    end
    it 'updates stackexchange information from serel API' do
      stackexchange.update_stackexchange
      stackexchange.display_name.should == serel_api.display_name
      stackexchange.reputation.should == serel_api.reputation
      stackexchange.age.should == serel_api.age
      stackexchange.badges.should == serel_api.badge_counts
    end
  end

  describe '#initialize_stackexchange' do
    it 'initializes a new Serel::AccessToken' do
      expect(Serel::AccessToken).to receive(:new).with(stackexchange.token)
      stackexchange.initialize_stackexchange
    end
  end

  describe '#get_stackexchange_user' do
    context 'valid request' do
      let(:serel_access) { double(Serel::AccessToken, user: serel_api) }
      before :each do
        expect(Serel::AccessToken).to receive(:new).with(stackexchange.token) { serel_access }
      end
      it 'gets users stackexchange information' do
        stackexchange.get_stackexchange_user.should == serel_api
      end
    end
    context 'invalid request, error raised' do
      before :each do
        expect(Serel::AccessToken).to receive(:new).with(stackexchange.token) { Serel::NoAPIKeyError }
      end
      it 'gets users stackexchange information' do
        expect(Rails.logger).to receive(:error)
        stackexchange.get_stackexchange_user
      end
    end
  end
end
