require 'spec_helper'

describe GithubAccount do
  it { should belong_to(:user) }
  it { should have_many(:repos) }
  it { should have_many(:organizations) }

  let(:generic_auth_github) {
    OpenStruct.new(uid: '123456789', info: auth_info,
      extra: extra_info_github, credentials: OpenStruct.new(token: Faker::Lorem.word)
    )
  }
  let(:user) { create(:user) }
  let(:extra_info_github) do
    OpenStruct.new(raw_info: OpenStruct.new(
      location: 'San Francisco, CA',
      hireable: true,
      bio: 'some bio',
      public_repos: 5,
      followers: 5,
      following: 5,
      public_gists: 5,
      id: generate(:guid)
    ))
  end
  let(:auth_info) do
    OpenStruct.new(
      image: 'image.png',
      name:  'Your Name',
      email: 'your@email.com',
      description: 'description',
      nickname: 'nickname'
    )
  end

  describe '#from_omniauth' do
    let(:github_account) { build(:github_account) }
    it 'sets attributes from github auth' do
      github_account.from_omniauth(generic_auth_github)
      github_account.nickname.should eq 'nickname'
      github_account.hireable.should be_true
      github_account.bio.should eq 'some bio'
      github_account.public_repos_count.should eq 5
      github_account.number_followers.should eq 5
      github_account.number_following.should eq 5
      github_account.number_gists.should eq 5
      github_account.uid.should eq '123456789'
    end
    context 'calling save' do
      before :each do
        expect(github_account).to receive(:save)
      end
      it 'calls save!' do
        github_account.from_omniauth(generic_auth_github)
      end
    end
    context 'after_create #grab_github_information' do
      before :each do
        expect(GithubWorker).to receive(:perform_async)
      end
      it 'runs a sidekiq job after create' do
        github_account.from_omniauth(generic_auth_github)
      end
    end
  end

  describe '#most_common_language' do
    let(:github_account) { create(:github_account, user: user) }
    let(:ruby_repos) { create_list(:repo, 5, github_account: github_account) }
    let(:java_repos) { create_list(:repo, 3, github_account: github_account, language: 'Java') }
    before :each do
      github_account.stub(:repos).and_return(ruby_repos + java_repos)
    end
    it 'returns most common language (Ruby)' do
      github_account.most_common_language.should == 'Ruby'
    end
  end

  describe '#get_org_information' do
    let(:github_account) { create(:github_account, user: user) }
    let(:github)         { double(Github, orgs: orgs) }
    context 'valid request' do
      let(:orgs)           { double(Github::Orgs, get: 'org info') }
      before :each do
        expect(Github).to receive(:new).with(oauth_token: github_account.token).and_return(github)
      end
      it 'returns information from API request' do
        github_account.get_org_information('test').should == 'org info'
      end
    end
    context 'error occurs' do
      before :each do
        expect(Github).to receive(:new).with(oauth_token: github_account.token).and_return(Github::Error::BadRequest)
      end
      it 'logs an error' do
        expect(Rails.logger).to receive(:error)
        github_account.get_org_information('test')
      end
    end
  end

  describe '#collected_org_keys' do
    let(:github_account) { create(:github_account, user: user) }
    let(:orgs) { create_list(:organization, 3, github_account: github_account) }
    before :each do
      github_account.stub(:organizations).and_return(orgs)
    end
    it 'collects organization keys (github org keys)' do
      github_account.collected_org_keys.should =~ orgs.collect { |org| org.organization_key }
    end
  end

  describe '#collected_repo_keys' do
    let(:github_account) { create(:github_account, user: user) }
    let(:repos) { create_list(:repo, 3, github_account: github_account) }
    before :each do
      github_account.stub(:repos).and_return(repos)
    end
    it 'collects organization keys (github org keys)' do
      github_account.collected_repo_keys.should =~ repos.collect { |repo| repo.repo_key }
    end
  end

  describe '#github_url' do
    let(:github_account) { create(:github_account, user: user) }
    it 'returns github url with github account nickname' do
      github_account.github_url.should eq "https://github.com/#{github_account.nickname}"
    end
  end
end
