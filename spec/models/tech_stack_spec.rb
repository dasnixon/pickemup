require 'spec_helper'

describe TechStack do
  describe '#attribute_default_values' do
    let(:tech_stack) { create(:tech_stack) }
    it 'returns the constant for the attribute' do
      tech_stack.attribute_default_values('back_end_languages').should eq TechStack::BACK_END_LANGUAGES
    end
  end

  describe '#get_attr_values' do
    context 'defaults only' do
      let(:tech_stack) { create(:tech_stack, dev_ops_tools: []) }
      let(:expected) do
        TechStack::DEV_OPS_TOOLS.collect { |p| { name: p, checked: false } }
      end
      it 'returns default constant values with false checked values' do
        tech_stack.get_attr_values('dev_ops_tools').should eq expected
      end
    end
    context 'data already set for attribute' do
      let(:tech_stack) { create(:tech_stack, dev_ops_tools: ['Chef', 'Puppet']) }
      let(:expected) do
        TechStack::DEV_OPS_TOOLS.collect do |p|
          case p
            when 'Chef', 'Puppet'
              { name: p, checked: true }
            else
              { name: p, checked: false }
          end
        end
      end
      it 'returns default constant values with false checked values' do
        tech_stack.get_attr_values('dev_ops_tools').should =~ expected
      end
    end
  end

  describe '.cleanup_invalid_data' do
    context 'skips' do
      let(:parameters) do
        {'blah' => 'fake'}
      end
      it 'does not have specific key' do
        TechStack.cleanup_invalid_data(parameters).should eq parameters
      end
    end
    context 'invalid data' do
      context 'attribute value not array' do
        let(:parameters) do
          {'dev_ops_tools' => 'fake'}
        end
        it 'removes the attribute from the parameter' do
          TechStack.cleanup_invalid_data(parameters).should_not have_key('dev_ops_tools')
        end
      end
    end
    context 'valid data' do
      context 'rejected' do
        let(:parameters) do
          {'dev_ops_tools' => [{'checked' => false, 'name' => Faker::Name.name},
                               {'checked' => false, 'name' => Faker::Name.name}]}
        end
        it 'sets attribute to empty array since rejected' do
          TechStack.cleanup_invalid_data(parameters).should eq({'dev_ops_tools' => []})
        end
      end
      context 'accepted' do
        let(:parameters) do
          {'dev_ops_tools' => [{'checked' => true, 'name' => 'Chef'},
                               {'checked' => true, 'name' => 'Puppet'}]}
        end
        it 'sets attribute to empty array since rejected' do
          TechStack.cleanup_invalid_data(parameters).should eq({'dev_ops_tools' => ['Chef', 'Puppet']})
        end
      end
    end
  end

  describe '.reject_attrs' do
    context 'rejected' do
      context 'does not have valid keys (checked, name)' do
        let(:param) do
          [{'test' => 'this'}]
        end
        it 'returns blank array' do
          TechStack.reject_attrs(param).should eq []
        end
      end
      context 'has more than 2 keys' do
        let(:param) do
          [{'checked' => true, 'name' => Faker::Name.name, 'test' => 'this'}]
        end
        it 'returns blank array' do
          TechStack.reject_attrs(param).should eq []
        end
      end
      context 'checked is not a boolean' do
        let(:param) do
          [{'checked' => 'haha', 'name' => Faker::Name.name}]
        end
        it 'returns blank array' do
          TechStack.reject_attrs(param).should eq []
        end
      end
      context 'attribute is not checked, set to true' do
        let(:param) do
          [{'checked' => false, 'name' => Faker::Name.name}]
        end
        it 'returns blank array' do
          TechStack.reject_attrs(param).should eq []
        end
      end
    end
    context 'accepted' do
      let(:param) do
        [{'checked' => true, 'name' => Faker::Name.name}]
      end
      it 'does not reject' do
        TechStack.reject_attrs(param).should eq param
      end
    end
  end
end
