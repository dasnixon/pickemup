require 'spec_helper'

describe PreferencesHelper do
  describe '#create_param_hash' do
    context 'Preference' do
      context 'checked values' do
        let(:expected) do
          [{name: 'test', checked: true}, {name: 'this', checked: true}]
        end
        it 'returns a collection of hashes with checked and name attributes' do
          Preference.create_param_hash(['test', 'this'], true).should eq expected
        end
      end
      context 'unchecked values' do
        let(:expected) do
          [{name: 'test', checked: false}, {name: 'this', checked: false}]
        end
        it 'returns a collection of hashes with checked and name attributes' do
          Preference.create_param_hash(['test', 'this'], false).should eq expected
        end
      end
    end
    context 'JobListing' do
      context 'checked values' do
        let(:expected) do
          [{name: 'test', checked: true}, {name: 'this', checked: true}]
        end
        it 'returns a collection of hashes with checked and name attributes' do
          JobListing.create_param_hash(['test', 'this'], true).should eq expected
        end
      end
      context 'unchecked values' do
        let(:expected) do
          [{name: 'test', checked: false}, {name: 'this', checked: false}]
        end
        it 'returns a collection of hashes with checked and name attributes' do
          JobListing.create_param_hash(['test', 'this'], false).should eq expected
        end
      end
    end
  end
end
