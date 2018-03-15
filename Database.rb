require 'mysql2'

class Database
  def self.makeQuery(queryString)
    return @@client.query(queryString).to_a
  end

  def self.connect
    @@client = Mysql2::Client.new(host:     'localhost',
                                  database: 'test',
                                  username: 'root',
                                  password: File.read('password.txt').chomp)
  end
end