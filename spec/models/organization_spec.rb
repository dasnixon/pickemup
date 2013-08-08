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
    context 'all new orgs' do
      before :each do
        Organization.any_instance.stub(:github_account).and_return(github_account)
        expect(github_account).to receive(:get_org_information).twice.and_return(auth_org)
        expect(StoreOrganizationLogo).to receive(:perform_async).twice
      end
      it 'creates new records' do
        expect { Organization.from_omniauth(user_orgs, github_account.id) }.to change(Organization, :count).by(user_orgs.length)
      end
    end
    #context 'an org found' do
      #let(:org_found) { create(:organization, organization_key: user_orgs.first.id, github_account: github_account) }
      #before :each do
        #expect(StoreOrganizationLogo).to receive(:perform_async).twice
        #Organization.any_instance.stub(:github_account).and_return(github_account)
        #expect(github_account).to receive(:get_org_information).twice.and_return(auth_org)
      #end
      #it 'creates only one new record' do
        #expect { Organization.from_omniauth(user_orgs, github_account.id) }.to change(Organization, :count).by(1)
      #end
    #end
    #context 'keys to remove present' do
      #context 'it calls remove_orgs' do
      #end
    #end
  end
end
