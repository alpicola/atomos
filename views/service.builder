xml.instruct! :xml, :version => "1.0", :encoding => 'UTF-8'
xml.service('xmlns'      => 'http://www.w3.org/2007/app',
						'xmlns:atom' => 'http://www.w3.org/2005/Atom') do
	xml.workspace do
		xml.tag! 'atom:title', @config.title
		xml.collection do
			xml.tag! 'atom:title', @config.title
			xml.accept 'application/atom+xml;type=entry'
		end
	end
end
