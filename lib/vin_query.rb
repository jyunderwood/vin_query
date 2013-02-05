# -*- encoding: utf-8 -*-
require 'vin_query/version'

require 'vin_query/exceptions'
require 'vin_query/trim_level'
require 'vin_query/query'

module VinQuery
  extend self

  def get(vin, options={})
    VinQuery::Query.new(vin, options).get
  end
end
