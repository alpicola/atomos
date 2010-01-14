require 'dm-core'
require 'dm-validations'
require 'dm-aggregates'
require 'rdiscount'
require 'date'

module Atomos
  class Entry
    include DataMapper::Resource

    property :id,        Serial
    property :slug,      String, :format => /\A[a-z0-9\-]+\z/
    property :title,     String, :length => (1..100)
    property :content,   Text
    property :updated,   DateTime
    property :published, DateTime, :default => lambda {|r,p| r.updated }
    validates_present :slug, :title, :content

    has n, :tags, :through => Resource

    default_scope(:default).update(:order => [:published.desc])

    def url
      "#{Application.url}/#{published.strftime('%Y/%m/%d')}/#{slug}"
    end

    def edit_url
      "#{Application.url}/atom/#{published.strftime('%Y/%m/%d')}/#{slug}"
    end

    def content
      @html ||= RDiscount.new(markdown).to_html
    end

    def markdown
      attribute_get(:content)
    end

    def tags(query=nil)
      relationships['tags'].get(self, query).map {|t| t.name }
    end

    def tags=(target)
      target = target.to_a.map {|t| Tag.first_or_create(:name => t) }
      relationships['tags'].set(self, target)
    end

    def self.tagged(tag)
      if tag = Tag.first(:name => tag)
        tag.entries
      else
        all.clear
      end
    end

    def self.circa(year, month=nil, day=nil)
      case
      when day
        from = Date.new(year.to_i, month.to_i, day.to_i)
        to   = from + 1
      when month
        from = Date.new(year.to_i, month.to_i, 1)
        to   = from >> 1
      when year
        from = Date.new(year.to_i, 1, 1)
        to   = Date.new(year.to_i + 1, 1, 1)
      end
      all(:published.gte => from, :published.lt => to)
    rescue ArgumentError => e
      all.clear
    end
  end

  class Tag
    include DataMapper::Resource

    property :id,   Serial
    property :name, String, :format => /\A[a-z0-9\-]+\z/

    has n, :entries, :through => Resource
  end
end
