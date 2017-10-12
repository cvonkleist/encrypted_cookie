require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('encrypted_cookie', '0.0.4') do |p|
  p.description    = "Encrypted session cookies for Rack"
  p.url            = "http://github.com/cvonkleist/encrypted_cookie"
  p.author         = "Christian von Kleist"
  p.email          = "cvonkleist at-a-place-called gmail.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.runtime_dependencies = ["rack >=1.1 <3"]
  p.development_dependencies = ["rack-test ~>0.6.2", "sinatra ~>1.3.4", "rspec ~>2.14.1"]
end
