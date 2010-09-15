class Post
  include DataMapper::Resource

  storage_names[:default] = 'stream'
  
  property :post_id, Integer, :key => true, :index => true
  property :source_id, Integer, :index => true
  property :created_time, EpochTime
end
