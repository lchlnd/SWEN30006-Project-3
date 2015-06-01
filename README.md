# SWEN30006 Project 3

## Setup

	bundle install
	rake db:drop
	rake db:setup
	rake weather:scrape_bom
	rake weather:scrape_forecast
	
Please allow 2-3 minutes for scrape_forecast to run.

## Scraping

While the server is running, data will be scraped from BOM every 10 minutes and forecast every 2 and a half hours.

## Viewing

	rails s

Go to `http://localhost:3000/`.
