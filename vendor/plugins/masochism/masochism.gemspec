
Gem::Specification.new do |s|
  s.name = %q{masochism}
  s.version = "0.0.1"
 
  s.specification_version = 1 if s.respond_to? :specification_version=
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Revolution Health"]
  s.autorequire = %q{masochism}
  s.date = %q{2009-01-23}
  s.description = %q{ActiveRecord connection proxy for master/slave connections}
  s.email = %q{rails@revolutionhealth.com}
  s.extra_rdoc_files = ["LICENSE", "README.markdown"]
  s.files = ["README.markdown", "lib/active_reload/connection_proxy.rb", "lib/active_reload/master_filter.rb", "lib/masochism.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/revolutionhealth/masochism/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.0.1}
  s.summary = %q{ActiveRecord connection proxy for master/slave connections}
end
