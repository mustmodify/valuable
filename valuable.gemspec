$:.push File.expand_path("../lib", __FILE__)  
version = File.read(File.expand_path("../valuable.version",__FILE__)).strip

spec = Gem::Specification.new do |s|
  s.name = 'valuable'
  s.version = version 
  s.summary = "attr_accessor on steroids with defaults, attribute formatting, alias methods, etc."
  s.description = "Valuable is a ruby base class that is essentially attr_accessor on steroids. A simple and intuitive interface allows you to get on with modeling in your app."
  s.license = 'MIT'

  s.require_path = 'lib'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.has_rdoc = true

  s.authors = ["Johnathon Wright"]
  s.email = "jw@mustmodify.com"
  s.homepage = "http://valuable.mustmodify.com/"
end

