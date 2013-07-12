require 'spec_helper'

describe GithubAccount do
  it { should belong_to(:user) }
  it { should have_many(:repos) }
  it { should have_many(:organizations) }
end
