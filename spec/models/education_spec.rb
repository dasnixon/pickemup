require 'spec_helper'

describe Education do
  it { should belong_to(:profile) }
end
