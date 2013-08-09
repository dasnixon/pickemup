require 'spec_helper'

describe Position do
  it { should belong_to(:profile) }

  let(:profile) { create(:profile) }

  let(:company) do
    { 'industry' => Faker::Lorem.word,
      'name'     => Faker::Company.name,
      'size'     => Faker::Lorem.word,
      'type'     => Faker::Lorem.word,
      'id'       => generate(:guid) }
  end
  let(:position) do
    { 'summary' => Faker::Lorem.sentences.join(' '),
      'isCurrent' => true,
      'startDate' =>
        { 'year' => '2012',
          'month' => '10'
        },
      'title' => Faker::Company.position }
  end

  let(:profile_auth) do
    {'positions' => { 'values' => [position.merge('company' => company)] }}
  end

  describe '.from_omniauth' do
    context 'valid auth data' do
      context 'no position keys' do
        it 'saves new records from linkedin auth' do
          expect { Position.from_omniauth(profile_auth, profile.id) }.to change(Position, :count).by(1)
        end
      end
      context 'keys to remove' do
        let(:ar_position) { create(:position) }
        let(:position_keys) do
          [ar_position.id]
        end
        before :each do
          expect(ar_position).to receive(:destroy) { true }
          expect(Position).to receive(:where).and_return([ar_position])
        end
        it 'removes any keys that should be removed' do
          expect { Position.from_omniauth(profile_auth, profile.id, position_keys) }.to change(Position, :count).by(1)
        end
      end
    end
    context 'invalid auth data' do
      let(:invalid_auth_data) do
        { 'positions' => nil }
      end
      it 'does nothing' do
        expect { Position.from_omniauth(invalid_auth_data, profile.id) }.to_not change(Position, :count).by(1)
      end
    end
  end

  describe '.remove_positions' do
    let(:ar_position) { create(:position) }
    let(:position_keys) do
      [ar_position.id]
    end
    it 'destroys records removed from linkedin profile' do
      expect(ar_position).to receive(:destroy) { true }
      expect(Position).to receive(:where).and_return([ar_position])
      Position.remove_positions(profile_auth['positions']['values'], position_keys)
    end
  end
end
