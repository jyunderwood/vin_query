# -*- encoding: utf-8 -*-

module VinQuery
  class TrimLevel
    attr_reader :attributes, :trim_level, :vin

    def initialize(vin, attributes)
      @vin = vin
      @attributes = attributes
      @trim_level = attributes[:trim_level]
    end

    def to_s
      "#{@vin} - #{@trim_level}"
    end
  end
end
