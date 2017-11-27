# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "encrypted_cookie"
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christian von Kleist"]
  s.date = "2011-03-03"
  s.description = "Encrypted session cookies for Rack"
  s.email = "cvonkleist at-a-place-called gmail.com"
  s.extra_rdoc_files = ["README.markdown", "lib/encrypted_cookie.rb"]
  s.files = ["Manifest", "README.markdown", "Rakefile", "encrypted_cookie.gemspec", "lib/encrypted_cookie.rb", "lib/encrypted_cookie/encryptor.rb", "spec/encrypted_cookie_spec.rb"]
  s.homepage = "http://github.com/cvonkleist/encrypted_cookie"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Encrypted_cookie", "--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "encrypted_cookie"
  s.rubygems_version = "2.0.3"
  s.summary = "Encrypted session cookies for Rack"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, ["< 3", ">= 1.1"])
      s.add_development_dependency(%q<rack-test>, ["~> 0.6.2"])
      s.add_development_dependency(%q<sinatra>, ["~> 1.3.4"])
      s.add_development_dependency(%q<rspec>, ["~> 2.14.1"])
    else
      s.add_dependency(%q<rack>, ["< 3", ">= 1.1"])
      s.add_dependency(%q<rack-test>, ["~> 0.6.2"])
      s.add_dependency(%q<sinatra>, ["~> 1.3.4"])
      s.add_dependency(%q<rspec>, ["~> 2.14.1"])
    end
  else
    s.add_dependency(%q<rack>, ["< 3", ">= 1.1"])
    s.add_dependency(%q<rack-test>, ["~> 0.6.2"])
    s.add_dependency(%q<sinatra>, ["~> 1.3.4"])
    s.add_dependency(%q<rspec>, ["~> 2.14.1"])
  end
end
