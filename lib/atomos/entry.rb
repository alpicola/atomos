require 'dm-core'
require 'dm-validations'
require 'dm-aggregates'
require 'maruku'
require 'date'

module Atomos
	class Entry
		include DataMapper::Resource

		property :id,        Serial
		property :slug,      String, :format => /\A[\w\-.~]+\z/
		property :title,     String
		property :content,   Text
		property :updated,   DateTime
		property :published, DateTime, :default => lambda {|r,p| r.updated }
		validates_present :slug, :title, :content

		default_scope(:default).update(:order => [:published.desc])

		def url
			"#{Application.url}/#{published.strftime('%Y/%m/%d')}/#{slug}"
		end

		def edit_url
			"#{Application.url}/atom/#{published.strftime('%Y/%m/%d')}/#{slug}"
		end

		def html 
			@html ||= Maruku.new(content).to_html
		end

		def self.circa(year, month=nil, day=nil)
			case
			when day
				from = Date.new(year, month, day)
				to   = from + 1
			when month
				from = Date.new(year, month, 1)
				to   = from >> 1
			when year
				from = Date.new(year, 1, 1)
				to   = Date.new(year + 1, 1, 1)
			end
			all(:published.gte => from, :published.lt => to)
		end
	end
end
