# -*- encoding: utf-8 -*-
require File.expand_path('../lib/vin_query/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Jonathan Underwood']
  gem.email         = ['jonathan@jyunderwood.com']
  gem.summary       = 'A ruby library for accessing vinquery.com'
  gem.description   = 'A ruby library for fetching and parsing VIN information from vinquery.com, a vehicle identification number decoding service.'
  gem.homepage      = 'https://github.com/jyunderwood/vin_query'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'vin_query'
  gem.require_paths = ['lib']
  gem.version       = VinQuery::VERSION

  gem.add_dependency 'libxml-ruby', '>= 2.3.3'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'fakeweb'
end
