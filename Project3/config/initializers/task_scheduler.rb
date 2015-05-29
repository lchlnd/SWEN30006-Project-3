require 'rubygems'
require 'rufus/scheduler'





scheduler = Rufus::Scheduler.new





#do every 30 minutes
scheduler.every '30m', :first_in =>'3s'  do
	
	#run bom scraper
	
	
	
	#run darksky scraper

end

