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
		page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
		page.xpath("//p/a").each do |name|
			townhall_names << name.text
		end
		return townhall_names
	end

	def get_townhall_urls # ici on récupère les urls
		townhall_url = []
		page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
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

	def make_the_hash(townhall_names, townhall_url, townhall_email) # ici on crée le hash final contenant toutes les informations
		hash_final = Hash[get_townhall_names.zip(get_townhall_email(get_townhall_urls))]
	  return hash_final
	end

# --------------------------------
#  Méthode qui permet d'exporter les données vers un fichier JSON
# --------------------------------

	def save_as_json(hash_final)
		File.open("/Users/noemargui/Desktop/THP/Week3/Day12/Mass_Data_Saving/db/emails.json","w") do |f|
			f.write(hash_final.to_json)
		end
	end

# --------------------------------
#  Méthode qui permet d'exporter les données vers mon fichier SpreadSheet : https://docs.google.com/spreadsheets/d/1WdQLc0yBbIqcyjyQGj3ZPAChYY5KHjltJDxogtcWgr8/edit#gid=0
# --------------------------------

	def save_as_spreadsheet(townhall_names, townhall_email)
		session = GoogleDrive::Session.from_config("config.json")
		ws = session.spreadsheet_by_key("1WdQLc0yBbIqcyjyQGj3ZPAChYY5KHjltJDxogtcWgr8").worksheets[0]
		ws[1, 1] = "Noms des Villes"
		i = 2
		y = 0
		while i < 186
			ws[i, 1] = townhall_names[y]
			i = i+1
			y = y+1
		end
		ws[1, 2] = "E-mails des dites mairie"
		i = 2
		y = 0
		while i < 186
			ws[i, 2] = townhall_email[y]
			i = i+1
			y = y+1
		end
		ws.save
	end

# --------------------------------
#  Méthode qui permet d'exporter les données vers un fichier CSV
# --------------------------------

	def save_as_csv(hash_final)
		CSV.open("/Users/noemargui/Desktop/THP/Week3/Day12/Mass_Data_Saving/db/emails.csv", "wb") {|csv| hash_final.to_a.each {|elem| csv << elem} }
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