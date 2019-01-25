require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'google_drive'
require 'csv'

class Scrapper

# --------------------------------
#  Ci-dessous les 4 méthodes me permettant de faire mon scrapping de mail proprement
# --------------------------------

	def get_townhall_names # ici on récupère les noms
		townhall_names = []
		page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/lot-et-garonne.html"))
		page.xpath("//p/a").each do |name|
			townhall_names << name.text
		end
		return townhall_names
	end

	def get_townhall_urls # ici on récupère les urls
		townhall_url = []
		page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/lot-et-garonne.html"))
		page.xpath("//p/a/@href").each do |hall|
			townhall_url << "http://annuaire-des-mairies.com" + hall.to_str[1..-1]
		end
		return townhall_url
	end

	def get_townhall_email(townhall_url) # ici on récupère les emails, grâce aux urls en placés en paramètres
	 townhall_email = []
	 townhall_url.each do |url_town|
	   page = Nokogiri::HTML(open(url_town))
	   page.xpath("/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]").each do |email|
	     townhall_email << email.text
	   end
	 end
	 return townhall_email
	end

	def get_townhall_department(townhall_url) # ici on récupère les emails, grâce aux urls en placés en paramètres
	 townhall_department = []
	 townhall_url.each do |url_town|
	   page = Nokogiri::HTML(open(url_town))
	   page.xpath("/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]").each do |email|
	     townhall_email << email.text
	   end
	 end
	 return townhall_email
	end

=begin
	def make_the_hash(townhall_names, townhall_url, townhall_email) # ici on crée le hash final contenant toutes les informations
		hash_final = Hash[get_townhall_names.zip(get_townhall_email(get_townhall_urls))]
	  return hash_final
	end
=end
# --------------------------------
#  Méthode qui permet d'exporter les données vers un fichier JSON
# --------------------------------

	def save_as_json(hash_final)
		File.open("/Users/noemargui/Desktop/THP/Week3/Day12/Mass_Data_Saving/db/emails.json","w") do |f|
			f.write(hash_final.to_json)
		end
	end
# --------------------------------
#  Mon perform qui permet de faire tourner toute la machine
# --------------------------------

	def perform
		townhall_names = get_townhall_names
		townhall_url = get_townhall_urls
		townhall_email = get_townhall_email(townhall_url)
		hash_final = make_the_hash(townhall_names, townhall_url, townhall_email)
		save_as_json(hash_final)
		save_as_spreadsheet(townhall_names, townhall_email)
		save_as_csv(hash_final)
	end

end