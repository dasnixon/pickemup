require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }
  let(:new_user) { FactoryGirl.build(:user) }

  it { should have_one(:github_account) }
  it { should have_one(:linkedin) }
  it { should have_one(:stackexchange) }

  describe '#from_omniauth' do
    context 'user found on lookup' do
      before :each do
        @auth = { uid: FactoryGirl.generate(:guid) }
        User.stub_chain(:where, :first_or_create).and_return(user)
        user.should_receive(:update_information).with(@auth).and_return(true)
      end
      it 'returns the user object' do
        User.from_omniauth(@auth).should == user
      end
      it 'newly created virtual attribute is nil on user' do
        user = User.from_omniauth(@auth)
        user.newly_created.should be_nil
      end
    end

    #context 'user not found on lookup' do
      #before :each do
        #auth = { uid: user.uid, info: { name: user.name, email: user.email }, extra: { raw_info: { location: user.location, blog: user.blog, company: user.current_company } } }
        #@auth = OpenStruct.new auth
        #User.stub_chain(:where, :first_or_create).and_return(new_user)
        #new_user.should_receive(:newly_created=)
        #new_user.should_receive(:set_attributes).with(@auth)
      #end
      #it 'returns the user object after it has been created' do
        #u = User.from_omniauth(@auth)
        #user.name.should == u.name
        #user.uid.should == u.uid
      #end
    #end
  end
end
