# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

URL = "http://www.bom.gov.au/vic/observations/vicall.shtml"
#URL = "http://www.bom.gov.au/vic/observations/melbourne.shtml #for testing smaller"
require 'nokogiri'
require 'open-uri'
require 'csv'

#Open the HTML link with Nokogiri
doc = Nokogiri::HTML(open(URL))

#Scarpe for Stations
stations = Array.new
#find the links to all the stations
doc.xpath("//tbody//a").each do |link|
	#create a new array for the station
	station = Array.new
	station.push(link.content) #This is the name of the station
	station.push(link['href']) #this is the link to that station
	#push this station into the stations array
	stations.push(station)
end


#Scrape for Station lat&lon
i=0
stations.each do |station|
	#if the station already exists no point scraping it again!
	if( (Location.where(["name = ?", "#{station[0]}"])).blank? )
		puts "Scraping station: #{station[0]}"
		stationDoc = Nokogiri::HTML(open("http://www.bom.gov.au"+station[1]))
		#pulls latitude
		stations[i].push( stationDoc.css("table.stationdetails").css("td")[3].text.match(/[-]?[1-9]+[.][0-9]+/)[0] )
		#pulls long
		stations[i].push( stationDoc.css("table.stationdetails").css("td")[4].text.match(/[-]?[1-9]+[.][0-9]+/)[0] )
		i += 1
	end
end

#Scrap Post codes from vicPostCodes.csv
#Then add
file = CSV.read("lib/assets/vicPostCodes.csv")

lastPostCode = 0
puts "Generating Post codes"
file.each do |row|
	#take each line from csv
	#we only want one post code per area
	if(lastPostCode != row[0])
		lastPostCode = row[0]
		code = row[0]
		lat  = row[5]
		lon  = row[6]

		#Create post codes in DB
		if(ActiveRecord::Base.connection.table_exists? 'postcodes')
			if( (Position.where("latitude = ? AND longitude = ?", "#{lat}","#{lon}")).blank?)
				#if there is no position create one
				newPos = Position.create({latitude: lat, longitude: lon})
				newPos.postcodes.create({code: code})
			end
		end
	end
end
puts "generated"
#Note there are still some post codes missing imbetween 3000-4000
#Because they do not exist! - need to be carefull of this later on

#function that finds closest poscode to a lat lon 
# & returns the last postcode made for that address
def belongsToWhichPostcode lat, lon
	smallestPostcode = Postcode
	smallestDist = 9999999999999999999.0
	#we want to look at all post codes & find closest
	Position.all.each do |pos|
		if pos.postcodes.last
			currentDist = Math.sqrt( ((pos.latitude.to_f - lat).abs)**2 + ((pos.longitude.to_f - lon).abs)**2 )
			if(currentDist < smallestDist)
				smallestDist     = currentDist
				smallestPostcode = pos.postcodes
			end
		end
	end
	#return the last postcode that was made for that position
	smallestPostcode.last
end

puts "Creating Locations (aka stations)"
#Go through each station and see if it exits in our model yet?
stations.each do |station|
	stationName = station[0]
	lat         = station[2]
	lon         = station[3]
	if (ActiveRecord::Base.connection.table_exists? 'locations')
		#if the station doesn't exist make one
		if( (Location.where(["name = ?", "#{stationName}"])).blank? )
			#create the stations position
			pos = Position.create({latitude: lat, longitude: lon})
			#find parent postcode
			parentPostcode = belongsToWhichPostcode(lat.to_f,lon.to_f)
			newLocation    = parentPostcode.locations.create({name: stationName, position_id: pos.id})
		end
	end
end
