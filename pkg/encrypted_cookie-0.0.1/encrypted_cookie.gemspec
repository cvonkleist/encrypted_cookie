# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{encrypted_cookie}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christian von Kleist"]
  s.cert_chain = ["/home/cvk/.gemcert/gem-public_cert.pem"]
  s.date = %q{2011-03-01}
  s.description = %q{Encrypted session cookies for Rack}
  s.email = %q{cvonkleist at-a-place-called gmail.com}
  s.extra_rdoc_files = ["lib/encrypted_cookie.rb"]
  s.files = ["Rakefile", "encrypted_cookie_spec.rb", "lib/encrypted_cookie.rb", "Manifest", "encrypted_cookie.gemspec"]
  s.homepage = %q{http://github.com/cvonkleist/encrypted_cookie}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Encrypted_cookie"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{encrypted_cookie}
  s.rubygems_version = %q{1.3.7}
  s.signing_key = %q{/home/cvk/.gemcert/gem-private_key.pem}
  s.summary = %q{Encrypted session cookies for Rack}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
