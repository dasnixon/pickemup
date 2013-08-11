require 'spec_helper'

describe Profile do
  it { should have_many(:positions) }
  it { should have_many(:educations) }
  it { should belong_to(:linkedin) }

  let(:profile_auth) do
    OpenStruct.new(
      summary: Faker::Lorem.sentences.join(' '),
      num_connections: 99,
      num_recommenders: 54,
      skills: skills
    )
  end

  let(:skills) do
    OpenStruct.new(total: 2, all: [OpenStruct.new(skill: OpenStruct.new(name: 'Ruby')), OpenStruct.new(skill: OpenStruct.new(name: 'Python'))])
  end

  let(:profile) { create(:profile) }

  describe '#from_omniauth' do
    let(:linkedin) { profile.linkedin }
    before :each do
      linkedin.stub(:get_profile).and_return(profile_auth)
      expect(Position).to receive(:from_omniauth)
      expect(Education).to receive(:from_omniauth)
    end
    it 'updates the profile with data from auth' do
      profile.from_omniauth
      profile.summary.should == profile_auth.summary
      profile.number_connections.should == profile_auth.num_connections
      profile.number_recommenders.should == profile_auth.num_recommenders
      profile.skills.should =~ ['Ruby', 'Python']
    end
    context 'receives update' do
      it 'makes #update call' do
        expect(profile).to receive(:update)
        profile.from_omniauth
      end
    end
  end

  describe '#collected_position_keys' do
    let(:position) { create(:position, position_key: 1) }
    let(:position2) { create(:position, position_key: 2) }
    before :each do
      expect(profile).to receive(:positions).and_return([position, position2])
    end
    it 'returns array of collected position_key from positions' do
      profile.collected_position_keys.should =~ [1, 2]
    end
  end

  describe '#collected_education_keys' do
    let(:education) { create(:education, education_key: 1) }
    let(:education2) { create(:education, education_key: 2) }
    before :each do
      expect(profile).to receive(:educations).and_return([education, education2])
    end
    it 'returns array of collected education_key from educations' do
      profile.collected_education_keys.should =~ [1, 2]
    end
  end

  describe '.get_skills' do
    it 'returns an array of skills from auth' do
      Profile.get_skills(skills).should =~ ['Ruby', 'Python']
    end
  end
end
