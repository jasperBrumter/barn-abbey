
class PagesController < ApplicationController

  def results
  	#on verifie que le token donne en parametre est le bon
  	@valid = params["token"] == "enigma"

  	#on trouve l'autre parametre qui contient ce que l'utilisateur a entre dans sa barre de recherche
  	@request = params["q"]

	#On fait une premiere requete a l'API Autocomplete de Google
  	placeresults = JSON.parse(HTTParty.get("https://maps.googleapis.com/maps/api/place/autocomplete/json?key=#{ENV['NOT_PUBLIC_KEY']}&input=#{@request}").to_s)
 	@autocomplete_result = (placeresults["predictions"].first)["description"]


 	#on utilise le Gem Geocoder pour trouver les latitudes longitudes de ce point
  	results = Geocoder.search(@autocomplete_result)
	@coordinates = results.first.coordinates

  	googleFile =  JSON.parse(HTTParty.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@coordinates[0]},#{@coordinates[1]}&radius=20000&type=bar&key=#{ENV['NOT_PUBLIC_KEY']}").to_s)["results"]
  	

	#add the results to the database if they don't exist yet
	googleFile.each do |x|
		if Place.where(name: x["name"]) == []
			Place.create({
				name: x["name"],
				latitude: x["geometry"]["location"]["lat"],
				longitude: x["geometry"]["location"]["lat"],
				found: "google",
				type_filter: x["types"],
				ambience_filter: [],
				has_offers: false,
				is_payment_available: false,
				is_booking_available: false,
				is_favorited: false,
				picture_url: "",
				address: x["vicinity"]
			})
		end
	end

	@places = Place.all.sort_by{|y| getDistanceFromLatLonInKm(y["latitude"].to_f,y["longitude"].to_f,@coordinates[0],@coordinates[1])}  
  end

  private
	def getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) 
		#rayon de la Terre en km
		earthRadius = 6371 
		#on calcule les differences en latitude et longitudes
		dLat = deg2rad(lat2-lat1)
		dLon = deg2rad(lon2-lon1)
		#on les transformes en radius grace a la fonction deg2rad
		#on trouve la formule suivante sur internet:
		a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * Math.sin(dLon/2) * Math.sin(dLon/2) 
		c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
		#on obtient la distance en km (float)
		d = earthRadius * c
		return d
	end

	def deg2rad(deg) 
		return deg * (Math::PI/180)
	end
end
