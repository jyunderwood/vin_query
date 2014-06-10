# -*- encoding: utf-8 -*-
require File.expand_path('../lib/vin_query/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'vin_query'
  gem.version       = VinQuery::VERSION
  gem.platform      = Gem::Platform::RUBY

  gem.summary       = 'A ruby library for accessing vinquery.com'
  gem.description   = 'A ruby library for fetching and parsing VIN information from vinquery.com, a vehicle identification number decoding service.'
  gem.homepage      = 'https://github.com/jyunderwood/vin_query'

  gem.authors       = ['Jonathan Underwood']
  gem.email         = ['jonathan@jyunderwood.com']

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'nokogiri', '> 1.5'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec'
end
