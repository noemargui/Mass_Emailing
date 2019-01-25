require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'

class Scrapper

	def get_townhall_names() # ici on récupère les noms
		townhall_names = []
		adresse = ["http://annuaire-des-mairies.com/lot-et-garonne.html", "http://annuaire-des-mairies.com/alpes-maritimes.html", "http://annuaire-des-mairies.com/hautes-alpes.html"]
		adresse.each do |adresse|
			page = Nokogiri::HTML(open(adresse))
			page.xpath("//p/a").each do |name|
				townhall_names << name.text
			end
			return townhall_names
		end
	end

	def get_townhall_urls() # ici on récupère les urls
		townhall_url = []
		adresse = ["http://annuaire-des-mairies.com/lot-et-garonne.html", "http://annuaire-des-mairies.com/alpes-maritimes.html", "http://annuaire-des-mairies.com/hautes-alpes.html"]
		adresse.each do |adresse|
			page = Nokogiri::HTML(open(adresse))
			page.xpath("//p/a/@href").each do |hall|
				townhall_url << "http://annuaire-des-mairies.com" + hall.to_str[1..-1]
			end
			return townhall_url
		end
	end

	def get_townhall_email(townhall_url) # ici on récupère les emails, grâce aux urls en placés en paramètres
		townhall_email = []
	 	townhall_url.each do |url_town|
			page = Nokogiri::HTML(open(url_town))
			page.xpath("/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]").each do |email|
				townhall_email << email.text
			end	
			return townhall_email
		end
	end

	def get_townhall_department(townhall_url) # ici on récupère les emails, grâce aux urls en placés en paramètres
		townhall_department = []
		townhall_url.each do |url_town|
			page = Nokogiri::HTML(open(url_town))
			page.xpath("/html/body/div/main/section[1]/div/div/div/p[1]/a").each do |department|
				townhall_department << department.text
			end
		end
		return townhall_department
	end

	def make_the_hash(townhall_names, townhall_url, townhall_email, townhall_department) # ici on crée le hash final contenant toutes les informations
		hash_final = townhall_names.zip(townhall_email, townhall_department)
	  return hash_final
	end

	def save_as_json(hash_final)
		File.open("db/emails.json","w") do |f|
			f.write(hash_final.to_json)
		end
	end

	def perform
		#departments = ["http://annuaire-des-mairies.com/lot-et-garonne.html", "http://annuaire-des-mairies.com/alpes-maritimes.html", "http://annuaire-des-mairies.com/hautes-alpes.html"]
		townhall_names = get_townhall_names()
		townhall_url = get_townhall_urls()
		townhall_email = get_townhall_email(townhall_url)
		townhall_department = get_townhall_department(townhall_url)
		hash_final = make_the_hash(townhall_names, townhall_url, townhall_email, townhall_department)
		save_as_json(hash_final).inspect
	end

end