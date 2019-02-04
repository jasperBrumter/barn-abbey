
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
  	@google_results_hash = googleFile.sort_by{|y| getDistanceFromLatLonInKm(y["geometry"]["location"]["lat"],y["geometry"]["location"]["lng"],@coordinates[0],@coordinates[1])}

  	#on ouvre le fichier extract.JSON qui contient les donnees (cela pourrait etre remplace par des entrees Active Records)
  	file = JSON.parse(File.read("public/extract.json"))
  	#on les parse dans un hash, qu'on ordonne ensuite selon la distance du point trouve par Geocoder.
	@data_hash = file["places"].sort_by{|y| getDistanceFromLatLonInKm(y["coordinates"]["latitude"],y["coordinates"]["longitude"],@coordinates[0],@coordinates[1])}  


	#on fait une liste jointe des deux,
	@ordered_list = []
	@google_results_hash.each do |place|
		@ordered_list << { place["name"] => getDistanceFromLatLonInKm(place["geometry"]["location"]["lat"],place["geometry"]["location"]["lng"],@coordinates[0],@coordinates[1]) }
	end
	@data_hash.each do |place|
		@ordered_list << { place["name"] => getDistanceFromLatLonInKm(place["coordinates"]["latitude"],place["coordinates"]["longitude"],@coordinates[0],@coordinates[1])}
	end
	#qu'on ordonne par distance
	@ordered_list.sort_by!{|y| y.values[0]}

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
