require "rubygems"
require "yaml"
require "twfy"

#dump all the current MPs to a YAML file

# Sign up for an API Key at TheyWorkForYou.com
api_key = "A6LGn2FvQdMEFsKDCbB46MCo"

puts "Connecting to TheyWorkForYou"

@client = Twfy::Client.new(api_key)

@mps = @client.mps

puts "Downloading #{@mps.size} MP profiles"
@full_mps = []
@count = @mps.size
@mps.each do |mp|
  @full_mps << @client.mp(:id=>mp.person_id).first
  @count = @count - 1
  puts "#{@count} : #{mp.name}"
end

puts "Writing to mps.yaml"
File.open('mps.yaml', 'w') do |out|
  out.write(@full_mps.to_yaml)
end

puts "We're all done!"