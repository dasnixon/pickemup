require 'spec_helper'

describe Linkedin do
  it { should belong_to(:user) }
  it { should have_one(:profile) }
end
