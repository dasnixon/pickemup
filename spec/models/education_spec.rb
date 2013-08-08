require 'spec_helper'

describe Education do
  it { should belong_to(:profile) }

  describe '#from_omniauth' do
    context 'no educations present' do
      before :each do
        Education.should_not_receive(:find_or_initialize_by)
      end
      it 'does not call .find_or_initialize' do
        Education.from_omniauth({}, 1).should be_nil
      end
    end
    context 'no values key' do
      before :each do
        Education.should_not_receive(:find_or_initialize_by)
      end
      it 'does not call .find_or_initialize' do
        Education.from_omniauth({'education' => {}}, 1).should be_nil
      end
    end
    context 'new education' do
      let(:auth) do
        {
          'educations' => {
            'values' => [{
              'id'             => 'education_key',
              'activities'     => 'activities',
              'degree'         => 'degree',
              'fieldOfStudy'   => 'field of study',
              'notes'          => 'notes',
              'schoolName'     => 'school name',
              'startDate'      => {
                'year'         => '2011'
              },
              'endDate'        => {
                'year'         => '2015'
              }
            }]
          }
        }
      end
      context 'initialization' do
        let(:profile) { create(:profile) }
        it 'initializes and updates education with auth data' do
          Education.from_omniauth(auth, profile.id)
          education = Education.first
          education.activities.should == 'activities'
          education.degree.should == 'degree'
          education.field_of_study.should == 'field of study'
          education.notes.should == 'notes'
          education.school_name.should == 'school name'
          education.start_year.should == '2011'
          education.end_year.should == '2015'
        end
      end
      context 'find' do
        let(:education) { create(:education) }
        let(:profile)   { education.profile }
        before :each do
          Education.stub(:find_or_initialize_by).and_return(education)
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
