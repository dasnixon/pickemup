require 'spec_helper'

describe Repo do
  it { should belong_to(:github_account) }

  let(:github_account) { create(:github_account) }
  let(:started) { 10.days.ago }
  let(:updated) { started + 3.days }
  before do
    Timecop.freeze(started)
  end
  after do
    Timecop.return
  end
  let(:repo_auth) do
    repos = []
    3.times do
      repos << OpenStruct.new(
                 name:            Faker::Lorem.word,
                 description:     Faker::Lorem.sentences.join(' '),
                 private:         false,
                 html_url:        Faker::Internet.http_url,
                 language:        Faker::Lorem.word,
                 number_forks:    5,
                 number_watchers: 6,
                 size:            150,
                 open_issues:     16,
                 created_at:      started,
                 last_updated:    updated,
                 id:              generate(:guid)
               )
    end
    repos
  end

  describe '.from_omniauth' do
    context 'no old repos to remove' do
      it 'creates new repos from auth' do
        expect { Repo.from_omniauth(repo_auth, github_account.id) }.to change(Repo, :count).by(3)
      end
    end
    context 'old repos to remove that are no longer on github' do
      let(:repo) { create(:repo, github_account: github_account) }
      let(:repo_keys) { [repo.id] }
      before :each do
        Repo.stub(:where).and_return([repo])
        expect(repo).to receive(:destroy)
      end
      it 'removes old repos' do
        expect { Repo.from_omniauth(repo_auth, github_account.id, repo_keys) }.to change(Repo, :count).by(3)
      end
    end
  end

  describe '#remove_repos' do
    let(:repo) { create(:repo, github_account: github_account) }
    let(:repo_keys) { [repo.id] }
    before :each do
      Repo.stub(:where).and_return([repo])
      expect(repo).to receive(:destroy)
    end
    it 'removes old repos' do
      Repo.remove_repos(repo_auth, repo_keys)
    end
  end
end
