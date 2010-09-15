require 'spec_helper'

describe DataMapper::Adapters::FqlAdapter do
  let(:adapter) { DataMapper.setup(:default, :adapter => :fql) }
  let(:repository) { DataMapper.repository(adapter.name) }
  subject { adapter }

  context 'when setting up with an options hash' do
    let(:adapter) { DataMapper.setup(:default, :adapter => :fql, :access_token => 'abcdef' ) }

    its(:session) { should be_instance_of(MiniFB::OAuthSession) }
  end
  
  context 'when setting up with an existing session' do
    let(:session) { MiniFB::OAuthSession.new('token') }
    subject { DataMapper.setup(:default, :adapter => :fql, :session => session) }

    its(:session) { should be_equal(session) }
  end
  
  describe '#compile' do
    subject { adapter.compile(query) }

    context 'when querying without a condition' do
      let(:query) { DataMapper::Query.new(repository, User)}
      
      specify { expect { subject }.to raise_error DataMapper::Adapters::NotSupportedError }
    end

    context 'when querying an unindexed column' do
      let(:query) { DataMapper::Query.new(repository, User, :conditions => { :sex => 'Male' }) }
      
      specify { expect { subject }.to raise_error DataMapper::Adapters::NotSupportedError }
    end
    
    context 'when querying an indexed column using equal' do
      let(:query) { DataMapper::Query.new(repository, User, :conditions => { :uid => 1 }) }
      it { should == "select uid, name from user where uid = 1" }

      context 'and an unindexed column as well' do
        let(:query) { DataMapper::Query.new(repository, User, :conditions => { :uid => 1, :sex => 'Male' }) }
        it { should include "select uid, name from user where" }
        it { should include "uid = 1" }
        it { should include "and" }
        it { should include "sex = 'Male'" }
      end
    end

    context 'when querying only a specific set of columns' do
      let(:query) { DataMapper::Query.new(repository, User, :conditions => { :uid => 1 }, :fields => [:name]) }
      it { should == "select name from user where uid = 1" }
    end

    context 'when querying a column using like' do
      let(:query) { DataMapper::Query.new(repository, User, :conditions => { :uid => 1, :name.like => '%Gabor%' }) }
      
      specify { expect { subject }.to raise_error DataMapper::Adapters::NotSupportedError }
    end

    context 'when querying a column using regexp' do
      let(:query) { DataMapper::Query.new(repository, User, :conditions => { :uid => 1, :name.regexp => /Gabor/ }) }
      
      specify { expect { subject }.to raise_error DataMapper::Adapters::NotSupportedError }
    end

    context 'when querying a column using not equal' do
      let(:query) { DataMapper::Query.new(repository, User, :conditions => { :uid => 1, :sex.not => 'Male' }) }
      it # { should == "select uid, name from user where uid = 1 and sex <> 'Male'" }
    end

    context 'when querying a column using greater than' do
      let(:query) { DataMapper::Query.new(repository, Post, :conditions => { :source_id => 1, :created_time.gt => Time.utc(2010, 9, 16) })}
      it { should include "select post_id, source_id, created_time from stream where" }
      it { should include "created_time > 1284595200" }
      it { should include "and" }
      it { should include "source_id = 1" }
    end

    context 'when querying a column using greater than or equal' do
      let(:query) { DataMapper::Query.new(repository, Post, :conditions => { :source_id => 1, :created_time.gte => Time.utc(2010, 9, 16) })}
      it { should include "select post_id, source_id, created_time from stream where" }
      it { should include "created_time >= 1284595200" }
      it { should include "and" }
      it { should include "source_id = 1" }
    end

    context 'when querying a column using less than' do
      let(:query) { DataMapper::Query.new(repository, Post, :conditions => { :source_id => 1, :created_time.lt => Time.utc(2010, 9, 16) })}
      it { should include "select post_id, source_id, created_time from stream where" }
      it { should include "created_time < 1284595200" }
      it { should include "and" }
      it { should include "source_id = 1" }
    end

    context 'when querying a column using less than or equal' do
      let(:query) { DataMapper::Query.new(repository, Post, :conditions => { :source_id => 1, :created_time.lte => Time.utc(2010, 9, 16) })}
      it { should include "select post_id, source_id, created_time from stream where" }
      it { should include "created_time <= 1284595200" }
      it { should include "source_id = 1" }
    end
    
    context 'when querying a column using set inclusion' do
      let(:query) { DataMapper::Query.new(repository, User, :conditions => { :uid => [1, 2] }) }
      it { should == "select uid, name from user where uid in (1, 2)" }
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
