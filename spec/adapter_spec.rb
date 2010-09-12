require 'spec_helper'

describe DataMapper::Adapters::FqlAdapter do
  let(:adapter) { DataMapper.setup(:default, :adapter => :fql) }
  let(:repository) { DataMapper.repository(adapter.name) }
  subject { adapter }

  context 'when setting up with an options hash' do
    subject { DataMapper.setup(:default, :adapter => :fql, :access_token => 'abcdef' ) }

    its(:session) { should be_instance_of(MiniFB::OAuthSession) }
  end
  
  context 'when setting up with an existing session' do
    let(:session) { MiniFB::OAuthSession.new('token') }
    subject { DataMapper.setup(:default, :adapter => :fql, :session => session) }

    its(:session) { should be_equal(session) }
  end
  
  describe '#compile' do
    context 'when querying for a single resource' do
      let(:query) { DataMapper::Query.new(repository, User, :conditions => { :uid => 1 }) }
      subject { adapter.compile(query) }
      
      it { should == "select uid, name from user where uid = 1" }
    end
  end
  
  describe '#read' do
    let(:session) { mock(MiniFB::OAuthSession) }
    let(:adapter) { DataMapper.setup(:default, :adapter => :fql, :session => session) }
    
    context 'when querying for a single resource' do
      let(:query) { mock(DataMapper::Query) }
      let(:fql) { 'select uid, name from user where uid = 1' }
      subject { adapter.read(query) }
      
      before do
        adapter.should_receive(:compile).with(query).and_return(fql)
        session.should_receive(:fql).with(fql).and_return([Hashie::Mash.new({:uid => 1, :name => 'Gabor Ratky'})])
      end
      
      it { should == [ { 'uid' => 1, 'name' => 'Gabor Ratky' }]}
    end
  end
end
