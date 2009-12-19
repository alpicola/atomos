require 'sinatra/base'
require 'erb'
require 'builder'
require 'rexml/document'
require 'digest/md5'
require 'date'
require 'time'

module Atomos
	class Application < Sinatra::Base

		# overrides Sinatra::Base's!
		def self.compile(path)
			keys = []
			if path.respond_to? :to_str
				special_chars = %w{. + ( )}
				patterns = { 'year' => /\d{4}/, 'month' => /\d{2}/, 'day' => /\d{2}/ }
				pattern =
					path.to_str.gsub(/(:(\w+)|[\*#{special_chars.join}])/) do |match|
						case match
						when "*"
							keys << 'splat'
							"(.*?)"
						when *special_chars
							Regexp.escape(match)
						else
							keys << $2
							"(#{patterns[$2] || '[^/?&#]+'})"
						end
					end
				[/^#{pattern}$/, keys]
			elsif path.respond_to?(:keys) && path.respond_to?(:match)
				[path, path.keys]
			elsif path.respond_to? :match
				[path, keys]
			else
				raise TypeError, path
			end
		end

		# default settings
		configure do
			set :root,   File.expand_path('../..', File.dirname(__FILE__))
			set :run,    true
			set :static, true

			set :url,    'http://localhost:4567'
			set :title,  'Atomos Blog'
			set :author, 'Anonymous'

			set :per_page, 10

			set :timezone, nil

			set :username,        'admin'
			set :realm,           'Atomos'
			set :password_digest, ''
			set :private_key,     ''
		end

		before do
			@config   = Application
			@title    = Application.title.dup
			@page     = 1
			@per_page = @config.per_page
			@pages    = (Entry.count + @per_page - 1) / @per_page
		end

		get '/' do
			@entries = Entry.all(:limit => @per_page)
			erb :home
		end

		get '/page/:page' do
			@page = params[:page].to_i
			raise NotFound unless (1..@pages).include? @page
			@entries = Entry.all(:offset => (@page-1) * @per_page, :limit => @per_page)
			erb :home
		end

		get '/:year/' do
			@entries = Entry.circa(params[:year].to_i)
			erb :home
		end

		get '/:year/:month/' do
			@entries = Entry.circa(params[:year].to_i, params[:month].to_i)
			erb :home
		end

		get '/:year/:month/:day/' do
			date = params.values_at(:year, :month, :day).map {|s| s.to_i }
			@entries = Entry.circa(*date)
			erb :home
		end

		get '/:year/:month/:day/:slug' do
			date = params.values_at(:year, :month, :day).map {|s| s.to_i }
			@entry = Entry.circa(*date).first(:slug => params[:slug]) or raise NotFound
			@title << ' - ' << @entry.title 
			erb :entry
		end

		get '/service/' do
			builder :service, :layout => false
		end

		get '/atom/' do
			@entries = Entry.all(:limit => 10)
			content_type 'application/atom+xml', :charset => 'utf-8'
			builder :feed, :layout => false
		end

		post '/atom/' do
			authorize!
			data = parse_xml(request.body.read).merge(:slug => request.env['HTTP_SLUG'])
			@entry = Entry.create(data) or error 400, 'Bad Reqest'
			status 201
			headers "Location" => @entry.url
			content_type 'application/atom+xml;type=entry', :charset => 'utf-8'
			builder :entry, :layout => false
		end

		get '/atom/:year/:month/:day/:slug' do
			authorize!
			date = params.values_at(:year, :month, :day).map {|s| s.to_i }
			@entry = Entry.circa(*date).first(:slug => params[:slug]) or raise NotFound
			content_type 'application/atom+xml;type=entry', :charset => 'utf-8'
			builder :entry, :layout => false
		end

		put '/atom/:year/:month/:day/:slug' do
			authorize!
			date = params.values_at(:year, :month, :day).map {|s| s.to_i }
			@entry = Entry.circa(*date).first(:slug => params[:slug]) or raise NotFound
			@entry.update(parse_xml(request.body.read)) or error 400, 'Bad Reqest'
			content_type 'application/atom+xml;type=entry', :charset => 'utf-8'
			builder :entry, :layout => false
		end

		delete '/atom/:year/:month/:day/:slug' do
			authorize!
			date = params.values_at(:year, :month, :day).map {|s| s.to_i }
			@entry = Entry.circa(*date).first(:slug => params[:slug]) or raise NotFound
			@entry.destroy!
			''
		end

		helpers do
			def authorize
				case request.env['HTTP_AUTHORIZATION']
				when /\ADigest\s*/
					header = {}
					$'.scan(/\w+\=(?:"[^"]+"|[^,]+)/) do |param|
						k, v = param.split('=', 2)
						header[k] = (/\A"(.*)"\Z/ =~ v) ? $1 : v
					end

					timestamp, digest = header['nonce'].unpack('m')[0].split(' ', 2)
					return unless md5(timestamp, @config.private_key) == digest &&
					              (Time.now - Time.iso8601(timestamp)) < 60

					header['a1'] = @config.password_digest
					header['a2'] = md5(request.request_method, header['uri'])
					header['response'] == md5(*header.values_at(*%w|a1 nonce nc cnonce qop a2|))
				end
			end

			def authorize!
				return if authorized?

				timestamp = Time.now.iso8601
				nonce = [timestamp, md5(timestamp, @config.private_key)].join(' ')
				headers 'WWW-Authenticate' => "Digest " + {
					'realm'     => '"%s"' % options.realm,
					'algorithm' => 'MD5',
					'qop'       => 'auth',
					'nonce'     => '"%s"' % [nonce].pack('m').gsub("\n", '')
				}.map {|i| i.join('=') }.join(', ')
				error 401, 'Authorization Required'
			end

			def authorized?
				@authorized ||= authorize
			end

			def md5(*args)
				Digest::MD5.hexdigest(args.join(':'))
			end

			def parse_xml(xml)
				now = DateTime.now
				if @config.timezone
					now = now.new_offset(@config.timezone.to_f / 24)
				end

				root = REXML::Document.new(xml).root
				root.elements.inject(nil, {'updated' => now}) do |entry, element|
					case element.name
					when 'title', 'content'
						entry[element.name] = element.text
					when 'updated', 'published'
						entry[element.name] = DateTime.strptime(element.text)
					end
					entry
				end
			rescue
				error 400, 'Bad Reqest'
			end
		end
	end
end
