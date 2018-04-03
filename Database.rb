require 'mysql2'

class Database

  def self.makeQuery(queryString)
    connect
    return @@client.query(queryString).to_a
  ensure
    @@client.close
  end

  def self.connect
    @@client = Mysql2::Client.new(host:     'localhost',
                                  database: 'pickupgames',
                                  username: 'root',
                                  password: File.read('password.txt').chomp)
  end
end