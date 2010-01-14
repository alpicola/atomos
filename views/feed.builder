xml.instruct! :xml, :version => "1.0", :encoding => 'UTF-8'
xml.feed(:xmlns => 'http://www.w3.org/2005/Atom') do
  xml.id      @config.url + '/'
  xml.title   @config.title
  xml.updated @entries.map {|entry| entry.updated }.max
  xml.link :rel => "alternate", :href => @config.url + '/'
  xml.link :rel => "self",      :href => @config.url + '/atom/'

  @entries.each do |entry|
    xml.entry do
      xml.id           entry.url
      xml.title        entry.title
      xml.content      entry.content, :type => 'html'
      xml.updated      entry.updated
      xml.published    entry.published
      xml.link :rel => "edit",      :href => entry.edit_url
      xml.link :rel => "alternate", :href => entry.url
      entry.tags.each do |tag|
        xml.category :term => tag
      end
    end
  end
end
