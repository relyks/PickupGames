require 'pp'
require 'securerandom'
require 'humanhash'

class Object
  def yield_self(*args)
    yield(self, *args)
  end
end

#puts (0..50_000).map { uid() }.group_by(&:itself).select { |k, v| k }

#puts (0..50_000).map { uid() }.group_by(&:itself).any? { |k, v| v.length > 2 }

sports = File.readlines('sport_kinds.txt')[2..-2].map { |e| e.chomp.split('|').map(&:strip).reject(&:empty?) }.map { |sport_kind, max_players| [sport_kind.split.map { |s| s =~ /\d/ ? s : s.capitalize } * ' ', max_players.to_i] }.to_h
sports
domains = %w[rutgers.edu gmail.com aol.com]
first_names = File.readlines('names.txt').map(&:chomp)
last_names = File.readlines('names2.txt').map(&:chomp)
names = first_names.product(last_names).sample(4000).map { |e| e << (e.map(&:downcase).join('.') + '@' + domains.sample) }
#pp names

location_names = File.readlines('president_names.txt').map { |e| e.split(',').first.split(' ').first }.uniq
location_names

sport_to_location_type = { 'tennis' => 'court', 'basketball' => 'court', 'hockey' => 'field', 'soccer' => 'field', 'softball' => 'field', 'football' => 'field'}

sport_to_sport_kind = sports.keys.map(&:split).map(&:last).zip(sports.keys).group_by(&:first).map { |k, v| [k, v.map { |x, y| y }] }.to_h

locations = location_names.dup
locs = sport_to_location_type.keys.map { |e| location = locations.delete_at(rand(locations.length)); (1..rand(2..4)).to_a.map { |l| ["#{location} #{e.capitalize} #{sport_to_location_type[e].capitalize} ##{l}", sport_to_sport_kind[e.capitalize].sample] } }.flatten(1)

now = Time.now
times = (1..20).map { |day| (8..22).map { |hour| Time.new(now.year, now.month, day, hour) } }.flatten

times_with_games = times.map { |time| [time] << (rand(2) == 1 ? [] : locs.sample(rand(1..locs.length))) }.to_h

final_games = times_with_games.map do |time, games|
  if games.empty?
    games_with_people = []
  else
    names_copy = names.dup
    games_with_people = games.map do |game_location, sport_kind|
      #pp sport_kind
      #pp sports[sport_kind]
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
end.to_h

final_games = final_games.map { |time, games| [time, games.map { |game| game << ['beginner', 'intermediate', 'advanced'].sample }] }.to_h

sports_table = sports.map { |sport, max_player_count| { sport_id: sport.split.join('-').downcase, sport: sport, number_of_players: max_player_count } }
locations_table = locs.map(&:first).map { |location| {location_id: location.delete('#').split.join('-').downcase, location: location } }
users = names.dup

games_table = []
plays_table = []
final_games.each do |time, games|
  next if games.empty?
  games.each do |location, sport_kind, players, skill_level|
    game_id = HumanHash.uuid.first
    games_table <<= { game_id: game_id, skill_level: skill_level, time: time, sport_kind: sport_kind.split.join('-').downcase, location: location.delete('#').split.join('-').downcase }
    plays_table <<= players.map { |player| { game_id: game_id, player: player.yield_self { |_, _, email| email } } }
  end
end

puts 'Sports Table'
puts sports_table
puts 'Locations Table'
puts locations_table
puts 'Games Table'
puts games_table
puts 'Plays Table'
puts plays_table