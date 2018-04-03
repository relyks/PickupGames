require 'pp'
require 'securerandom'
require 'humanhash'
require 'uri'
require_relative 'SportsGameManager.rb'
require_relative 'UserManager.rb'

class Object
  def yield_self(*args)
    yield(self, *args)
  end
end


sports = File.readlines('sport_kinds.txt').slice(2..-2).map { |e| e.chomp.split('|').map(&:strip).reject(&:empty?) }.map { |sport_kind, max_players| [sport_kind.split.map { |s| s =~ /\d/ ? s : s.capitalize } * ' ', max_players.to_i] }.to_h
domains = %w[rutgers.edu gmail.com aol.com]
first_names = File.readlines('names.txt').map(&:chomp).reject { |e| e =~ /[^a-z]/i }
last_names = File.readlines('names2.txt').map(&:chomp).reject { |e| e =~ /[^a-z]/i }
names = first_names.product(last_names).sample(4000).map { |e| e << (e.map(&:downcase).join('.') + '@' + domains.sample) }

location_names = File.readlines('president_names.txt').map { |e| e.split(',').first.split(' ').first }.uniq

sport_to_location_type = { 'tennis' => 'court', 'basketball' => 'court', 'hockey' => 'field', 'soccer' => 'field', 'softball' => 'field', 'football' => 'field'}

sport_to_sport_kind = sports.keys.map(&:split).map(&:last).zip(sports.keys).group_by(&:first).map { |k, v| [k, v.map { |x, y| y }] }.to_h
puts sport_to_sport_kind

locations = location_names.dup
locs = sport_to_location_type.keys.map { |e| location = locations.delete_at(rand(locations.length)); (1..rand(2..4)).to_a.map { |l| ["#{location} #{e.capitalize} #{sport_to_location_type[e].capitalize} ##{l}", sport_to_sport_kind[e.capitalize].sample] } }.flatten(1)
can_host_table = []
locs.map(&:first).each do |location_name, _|
  can_host_table <<= {locationID: location_name.delete('#').split.join('-').downcase, sportID: sport_to_sport_kind[sport_to_sport_kind.keys[sport_to_sport_kind.keys.index { |sport| location_name.downcase.include?(sport.downcase) }]] }
end
#puts can_host_table
can_host_table = can_host_table.reduce([]) do |collection, row|
  #puts row[:sportID]
  collection << row[:sportID].map { |sport| { locationID: row[:locationID], sportID: sport.split.join('-').downcase } }
end

now = Time.now
times = ((now.day + 1)..20).map { |day| (8..22).map { |hour| Time.new(now.year, now.month, day, hour) } }.flatten

times_with_games = times.map { |time| [time] << (rand(2) == 1 ? [] : locs.sample(rand(1..locs.length))) }.to_h

final_games = times_with_games.map { |time, games|
  if games.empty?
    games_with_people = []
  else
    names_copy = names.dup
    games_with_people = games.map do |game_location, sport_kind|
      number_of_people_to_sample = case rand(3)
                                   when 0
                                     1
                                   when 1
                                     rand(1..(sports[sport_kind] * 3 / 4))
                                   when 2
                                     sports[sport_kind]
                                   end
      [game_location, sport_kind, Array.new(number_of_people_to_sample) { names_copy.delete_at(rand(names_copy.length)) }]
    end
  end
  [time, games_with_people]
}.to_h

final_games = final_games.map { |time, games| [time, games.map { |game| game << ['beginner', 'intermediate', 'advanced'].sample }] }.to_h

sports_table = sports.map { |sport, max_player_count| { sportID: sport.split.join('-').downcase, sportType: sport, numberOfPlayers: max_player_count } }
locations_table = locs.map(&:first).map { |location| { locationID: location.delete('#').split.join('-').downcase, locationName: location } }
users = names.dup

games_table = []
plays_table = []
final_games.each do |time, games|
  next if games.empty?
  games.each do |location, sport_kind, players, skill_level|
    game_id = HumanHash.uuid.first
    games_table <<= { gameID: game_id, skillLevel: skill_level, startTime: time, sportID: sport_kind.split.join('-').downcase, locationID: location.delete('#').split.join('-').downcase }
    plays_table <<= players.map { |player| { gameID: game_id, email: player.yield_self { |_, _, email| email } } }
  end
end

# puts 'Sports Table'
# puts sports_table
# puts 'Locations Table'
# puts locations_table
# puts 'Games Table'
# puts games_table
#puts 'Plays Table'
plays_table.flatten!

#pp plays_table
#puts 'Can Host Table'
can_host_table.flatten!

# 5.times { puts }

# puts 
# game_ids = games_table.map { |g| g[:game_id].length }
# game_ids_average_length = game_ids.reduce(0) { |sum, i| sum + i } / game_ids.length
# puts game_ids_average_length

puts URI.encode_www_form({:game_id=>"purple-four-bakerloo-high", :player=>"rosalie.cristobal@gmail.com"})

names.each { |firstName, lastName, email| UserManager.createNewUser(firstName: firstName, lastName: lastName, username: email, password: 'password') }

sports_table.each { |sport| SportsGameManager.createSport(sport) }

locations_table.each { |location| SportsGameManager.createLocation(location) }

games_table.each { |game| SportsGameManager.createGame(**game, finalGame: false) }

pp plays_table

plays_table.each { |e| SportsGameManager.createUserPlaysGameRelation(e) }

pp can_host_table

can_host_table.each { |e| SportsGameManager.createLocationHostsSportRelation(e) }