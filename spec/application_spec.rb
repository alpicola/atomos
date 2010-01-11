require 'pathname'

$LOAD_PATH << Pathname.new(__FILE__).parent.parent + 'lib'

require 'rubygems'
require 'spec'
require 'rack/test'
require 'wsse'
require 'rexml/document'
require 'atomos'

include Atomos

Atomos.configure({
  :environment => :test,
  :database    => 'sqlite3::memory:',
  :username    => 'admin',
  :password    => 'password',
  :timestamp   => '00:00'
})

describe Application do
  include Rack::Test::Methods

  def app
    Application
  end

  before :all do
    Entry.create({
      :slug    => 'slug',
      :title   => 'title',
      :content => 'content',
      :updated => DateTime.new(2000, 1, 1, 0, 0, 0, 0)
    })
  end

  it 'should show a blog top page' do
    get('/').status.should == 200
  end

  it 'should show an entry page' do
    get('/2000/01/01/slug').status.should == 200
  end

  it 'should not show a nonexistent entry page' do
    get('/1999/01/01/slug').status.should == 404
  end

  it 'should accept GET request sent to Member URI' do
    lambda {
      header 'X-WSSE', WSSE.header('admin', 'password')
      get('/atom/2000/01/01/slug')
    }.should_not change(Entry, :count)

    last_response.status.should == 200
    doc = REXML::Document.new(last_response.body)
    doc.elements['/entry/title'].text.should == 'title'
    doc.elements['/entry/content'].text.should == "<p>content</p>\n"
  end

  it 'should accept POST request sent to Collection URI' do
    lambda {
      header 'Slug', 'slug'
      header 'X-WSSE', WSSE.header('admin', 'password')
      post('/atom/', <<-ENTRY)
        <entry xmlns="http://www.w3.org/2005/Atom">
          <title>title</title>
          <content type="text/plain">content</content>
          <published>2001-01-01T00:00:00Z</published>
        </entry>
      ENTRY
    }.should change(Entry, :count).by(1)

    last_response.status.should == 201
    doc = REXML::Document.new(last_response.body)
    doc.elements['/entry/title'].text.should == 'title'
    doc.elements['/entry/content'].text.should == "<p>content</p>\n"
  end

  it 'should accept PUT request sent to Member URI' do
    lambda {
      header 'X-WSSE', WSSE.header('admin', 'password')
      put('/atom/2001/01/01/slug', <<-ENTRY)
        <entry xmlns="http://www.w3.org/2005/Atom">
          <title>modified title</title>
          <content type="text/plain">modified content</content>
        </entry>
      ENTRY
    }.should_not change(Entry, :count)

    last_response.status.should == 200
    doc = REXML::Document.new(last_response.body)
    doc.elements['/entry/title'].text.should == 'modified title'
    doc.elements['/entry/content'].text.should == "<p>modified content</p>\n"
  end

  it 'should accept DELETE request sent to Member URI' do
    lambda {
      header 'X-WSSE', WSSE.header('admin', 'password')
      delete('/atom/2001/01/01/slug')
    }.should change(Entry, :count).by(-1)

    last_response.status.should == 200
  end

  it 'should not accept unauthorized request' do
    lambda {
      header 'X-WSSE', WSSE.header('admin', 'wrong password')
      get('/atom/2000/01/01/slug')
    }.should_not change(Entry, :count)

    last_response.status.should == 401
  end

  it 'should not accept POST request with a malformed entity body' do
    lambda {
      header 'Slug', 'slug'
      header 'X-WSSE', WSSE.header('admin', 'password')
      post('/atom/', <<-ENTRY)
        <entry xmlns="http://www.w3.org/2005/Atom">
          <title>this entry has no content</title>
        </entry>
      ENTRY
    }.should_not change(Entry, :count)

    last_response.status.should == 400

    lambda {
      header 'Slug', 'slug'
      header 'X-WSSE', WSSE.header('admin', 'password')
      post('/atom/', <<-ENTRY)
        <entry xmlns="http://www.w3.org/2005/Atom">
          <title>title<title>
          <content type="text/plain">content</content>
        </entry>
      ENTRY
    }.should_not change(Entry, :count)

    last_response.status.should == 400
  end

end
