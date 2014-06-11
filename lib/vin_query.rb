require 'vin_query/version'

require 'vin_query/exceptions'
require 'vin_query/trim_level'
require 'vin_query/query'

module VinQuery
  extend self

  def get(vin, options={})
    query = VinQuery::Query.new(vin, options)
    query.get()

    return query
  end
end
