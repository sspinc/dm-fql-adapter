class User
  include DataMapper::Resource

  property :uid, Integer, :key => true
  property :name, String
end
