require 'spec_helper'

describe Education do
  it { should belong_to(:profile) }

  let(:auth) { OpenStruct.new(educations: education_all) }
  let(:education_all) do
    OpenStruct.new(all: education_values, total: 1)
  end
  let(:education_values) do
    [OpenStruct.new(
      id: 'education_key',
      activities: 'activities',
      degree: 'degree',
      field_of_study: 'field of study',
      notes: 'notes',
      school_name: 'school name',
      start_date: OpenStruct.new(year: '2011'),
      end_date: OpenStruct.new(year: '2015')
    )]
  end

  describe '#from_omniauth' do
    context 'no educations present' do
      let(:education_all) { OpenStruct.new(all: {}, total: 0) }
      before :each do
        Education.should_not_receive(:where)
      end
      it 'does not call .where' do
        Education.from_omniauth(auth, 1).should be_nil
      end
    end
    context 'new education' do
      context 'initialization' do
        let(:profile) { create(:profile) }
        context 'calls update' do
          before :each do
            Education.any_instance.should_receive(:update).once
          end
          it 'initializes and updates education with auth data' do
            Education.from_omniauth(auth, profile.id)
          end
        end
        it 'initializes and updates education with auth data' do
          expect { Education.from_omniauth(auth, profile.id) }.to change(Education, :count).by(1)
        end
      end
      context 'find' do
        let(:education) { create(:education) }
        let(:profile)   { education.profile }
        before :each do
          Education.stub_chain(:where, :first_or_initialize).and_return(education)
        end
        it 'finds and updates education with auth data' do
          Education.from_omniauth(auth, profile.id)
          education.activities.should == 'activities'
          education.degree.should == 'degree'
          education.field_of_study.should == 'field of study'
          education.notes.should == 'notes'
          education.school_name.should == 'school name'
          education.start_year.should == '2011'
          education.end_year.should == '2015'
        end
      end
    end
  end
end
