# VinQuery

[![Build Status](https://travis-ci.org/jyunderwood/vin_query.png?branch=master)](https://travis-ci.org/jyunderwood/vin_query)

A ruby library for fetching and parsing VIN information from vinquery.com, a vehicle identification number decoding service.

Note, this gem is not officially affiliated with vinquery.com.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vin_query'
```

And then execute:

    bundle

Or install it yourself as:

    gem install vin_query

## Usage

Pass in the URL and access code provided by vinquery.com as well as the report type you want (defaults to report type '2' -- the extended report type).

Note, A VinQuery::Query class has an array of trim levels. This is due to the VinQuery service returning a array of possible trim levels for certain makes/models.

```ruby
query = VinQuery.get('1C3CC4FB8AN236750',
                     url: 'vinquery-url-here',
                     access_code: 'access-code-here',
                     report_type: 'report-type-here')

query.valid? # => true

## Configuration

It also accepts a configuration block to streamline gets.

```ruby
VinQuery.configure do |config|
  config.url = 'vinquery-url-here'
  config.access_code = 'access-code-here'
  config.report_type = 2
end

query = VinQuery.get('1C3CC4FB8AN236750')
query.valid? # => true
```

# Note, trim_levels will always be an array. Empty, or otherwise.
vehicle = query.trim_levels.first

vehicle.attributes[:make]              # => Chrysler
vehicle.attributes[:model]             # => Sebring
vehicle.attributes[:trim_level]        # => Sedan Touring
vehicle.attributes[:fuel_economy_city] # => 21
```

## Resources

- [vinquery.com FAQ](http://www.vinquery.com/faq.aspx)
- [VinQuery RubyGems page](https://rubygems.org/gems/vin_query)
- [VinQuery Travis CI page](https://travis-ci.org/jyunderwood/vin_query)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Licensed under the MIT License.
