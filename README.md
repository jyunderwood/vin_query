# VinQuery

A ruby library for fetching and parsing VIN information from vinquery.com, a vehicle identification number decoding service.

## Ruby requirements

Currently requires version 1.9.3.

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

Pass in the URL and access code provided by vinquery.com as well as the report type you want.

Note, the VinQuery class has an array of errors and array of vehicles. This is due to the VinQuery service returning a array of possible trim levels for certain vehicles.

```ruby
query = VinQuery.get('1C3CC4FB8AN236750', {
                      url: 'vinquery-url-here',
                      access_code: 'access-code-here',
                      report_type: 'report-type-here' })

query.valid?                           # => true

# Note, vehicles will always be an array. Empty, or otherwise.
vehicle = query.vehicles.first

vehicle.attributes[:make]              # => Chrysler
vehicle.attributes[:model]             # => Sebring
vehicle.attributes[:trim_level]        # => Sedan Touring
vehicle.attributes[:fuel_economy_city] # => 21
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Licensed under the MIT License.
