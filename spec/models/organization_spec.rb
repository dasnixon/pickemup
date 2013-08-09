require 'spec_helper'

describe Organization do
  it { should belong_to(:github_account) }

  let(:github_account) { create(:github_account) }
  let(:auth_org) do
    OpenStruct.new(
      name: Faker::Name.name,
      html_url: Faker::Internet.http_url,
      location: "#{Faker::Address.city}, #{Faker::AddressUS.state}",
      type: Faker::Lorem.word,
      blog: Faker::Internet.http_url,
      followers: 35,
      following: 45,
      public_repos: 50
    )
  end
  let(:user_orgs) do
    [
      OpenStruct.new(
        id: generate(:guid),
        login: Faker::Lorem.word
      ),
      OpenStruct.new(
        id: generate(:guid),
        login: Faker::Lorem.word
      )
    ]
  end

  describe '.from_omniauth' do
    before :each do
      Organization.any_instance.stub(:github_account).and_return(github_account)
      expect(github_account).to receive(:get_org_information).twice.and_return(auth_org)
      expect(StoreOrganizationLogo).to receive(:perform_async).twice
    end
    context 'no org keys passed' do
      it 'creates new records from auth' do
        expect { Organization.from_omniauth(user_orgs, github_account.id) }.to change(Organization, :count).by(user_orgs.length)
      end
    end
    context 'org_keys present' do
      context 'orgs have been removed' do
        let(:org_keys) { user_orgs.collect { |o| o.id } + [org.organization_key] }
        let(:org) { create(:organization, github_account: github_account, organization_key: generate(:guid)) }
        before :each do
          expect(Organization).to receive(:where).and_return([org])
          expect(org).to receive(:destroy) { true }
        end
        it 'destroys an organization that has been removed on github' do
          expect { Organization.from_omniauth(user_orgs, github_account.id, org_keys) }.to change(Organization, :count).by(user_orgs.length)
        end
      end
    end
  end

  describe '.remove_orgs' do
    let(:org_keys) { user_orgs.collect { |o| o.id } + [org.organization_key] }
    let(:org) { create(:organization, github_account: github_account, organization_key: generate(:guid)) }
    before :each do
      expect(Organization).to receive(:where).and_return([org])
      expect(org).to receive(:destroy) { true }
    end
    it 'removes any orgs that are in our system no longer on github' do
      Organization.remove_orgs(user_orgs, org_keys)
    end
  end

  describe '#set_organization_logo' do
    let(:org) { create(:organization, github_account: github_account) }
    let(:image_url) { Faker::Internet.http_url }
    context 'valid upload to S3' do
      before :each do
        expect(org).to receive(:remote_logo_url=).with(image_url)
        expect(org).to receive(:save!)
      end
      it 'sets logo from image_url' do
        org.set_organization_logo(image_url)
      end
    end
    context 'invalid upload, error' do
      before :each do
        expect(org).to receive(:remote_logo_url=).with(image_url).and_raise(CarrierWave::UploadError)
        expect(org).to_not receive(:save!)
        expect(Rails.logger).to receive(:error)
      end
      it 'logs an error' do
        org.set_organization_logo(image_url)
      end
    end
  end
end
