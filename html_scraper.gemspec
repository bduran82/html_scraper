# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'html_scraper/version'

Gem::Specification.new do |spec|
  spec.name          = 'html_scraper'
  spec.version       = HtmlScraper::VERSION
  spec.authors       = ['Bernat Duran']

  spec.summary       = 'Parses the data contained in a html web page to json using a user-defined'
  spec.homepage      = 'https://github.com/bduran82/html_scraper.git'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '~> 1.6'
  spec.add_dependency 'activesupport', '~> 4'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry'
end
