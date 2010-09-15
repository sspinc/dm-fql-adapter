class User
  include DataMapper::Resource

  property :uid, Integer, :key => true, :index => true
  property :name, String, :index => true
  property :sex, String, :lazy => true
end
