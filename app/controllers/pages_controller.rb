
class PagesController < ApplicationController

  def results
  	#on verifie que le token donne en parametre est le bon
  	@valid = params["token"] == "enigma"

  	#on trouve l'autre parametre qui contient ce que l'utilisateur a entre dans sa barre de recherche
  	@request = params["q"]

  	#on utilise le gem Geocoder pour trouver gratuitement les latitudes-longitudes. Il est dans la plupart des cas aussi precis que l'API de Google.
  	results = Geocoder.search(@request)
	@coordinates = results.first.coordinates

	key = ENV[G_K]

	#Mais si l'on voulait obtenir un resultat plus precis que Geocoder, en utilisant par exemple l'API Autocomplete on le ferait ainsi:
  	#@googleresults = JSON.parse(open("https://maps.googleapis.com/maps/api/place/autocomplete/json?key=#{ENV(G_K)}&input=#{@request}"))

  	@placeSearch =  HTTParty.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=#{key}&type=bar&location=#{@coordinates[0]},#{@coordinates[1]}&radius=20000&rankby=distance&query=#{@request}")

  	#on ouvre le fichier extract.JSON qui contient les donnees (cela pourrait etre remplace par des entrees Active Records)
  	file = JSON.parse(File.read("public/extract.json"))
  	#on les parse dans un hash, qu'on ordonne ensuite selon la distance du point trouve par Geocoder.
	@data_hash = file["places"].sort_by{|y| getDistanceFromLatLonInKm(y["coordinates"]["latitude"],y["coordinates"]["longitude"],@coordinates[0],@coordinates[1])}  	
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