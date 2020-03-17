# -*- encoding: utf-8 -*-
# stub: encrypted_cookie 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "encrypted_cookie".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Christian von Kleist".freeze]
  s.date = "2020-03-17"
  s.description = "Encrypted session cookies for Rack".freeze
  s.email = "cvonkleist at-a-place-called gmail.com".freeze
  s.extra_rdoc_files = ["LICENSE".freeze, "README.markdown".freeze, "lib/encrypted_cookie.rb".freeze, "lib/encrypted_cookie/encryptor.rb".freeze]
  s.files = ["Gemfile".freeze, "LICENSE".freeze, "Manifest".freeze, "README.markdown".freeze, "Rakefile".freeze, "encrypted_cookie.gemspec".freeze, "lib/encrypted_cookie.rb".freeze, "lib/encrypted_cookie/encryptor.rb".freeze, "spec/encrypted_cookie_spec.rb".freeze]
  s.homepage = "http://github.com/cvonkleist/encrypted_cookie".freeze
  s.rdoc_options = ["--line-numbers".freeze, "--title".freeze, "Encrypted_cookie".freeze, "--main".freeze, "README.markdown".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Encrypted session cookies for Rack".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rack>.freeze, [">= 1.1", "< 3"])
    s.add_development_dependency(%q<rack-test>.freeze, ["~> 0.6.2"])
    s.add_development_dependency(%q<sinatra>.freeze, ["~> 1.3.4"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 2.14.1"])
  else
    s.add_dependency(%q<rack>.freeze, [">= 1.1", "< 3"])
    s.add_dependency(%q<rack-test>.freeze, ["~> 0.6.2"])
    s.add_dependency(%q<sinatra>.freeze, ["~> 1.3.4"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.14.1"])
  end
end
