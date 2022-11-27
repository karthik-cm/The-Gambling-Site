require 'dm-core'
require 'dm-migrations'

# DataMapper.setup(:default,"sqlite3://#{Dir.pwd}/user.db")

class User
  include DataMapper::Resource
  property :id, Serial
  property :username, String
  property :password, String
  property :total_won, Integer
  property :total_lost, Integer
  property :total_profit, Integer
end
DataMapper.finalize


configure :development, :test do
    DataMapper.setup(:default,"sqlite3://#{Dir.pwd}/user.db")
end

configure :production do
    DataMapper.setup(:default,ENV['DATABASE_URL'])
end

#DataMapper.auto_migrate!
#User.auto_upgrade!