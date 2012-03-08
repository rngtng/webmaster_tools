# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "webmaster_tools"
  s.version     = File.read("VERSION").to_s.strip
  s.authors     = ["Tobias Bielohlawek"]
  s.email       = ["tobi@soundcloud.com"]
  s.homepage    = "http://github.com/rngtng/webmaster_tools"
  s.summary     = %q{Get programmatically access to Webmaster Tools Interface data}
  s.description = %q{Webmaster Tools extends the official API to give programmatically access to various crawl information and functions which are available via the webinterface}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  %w(mechanize).each do |gem|
    s.add_runtime_dependency *gem.split(' ')
  end

  %w(rake rspec vcr webmock).each do |gem|
    s.add_development_dependency *gem.split(' ')
  end
end
