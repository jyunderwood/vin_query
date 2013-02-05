# -*- encoding: utf-8 -*-
require 'net/http'
require 'nokogiri'

module VinQuery
  class Query
    attr_reader :url, :trim_levels

    def initialize(vin, options={})
      url = options[:url]
      access_code = options[:access_code]
      report_type = 2 || options[:report_type]

      @trim_levels = []
      @url = "#{url}?accessCode=#{access_code}&vin=#{vin}&reportType=#{report_type}"
    end

    def valid?
      @valid
    end

    def validate(xml)
      doc = Nokogiri::XML xml

      if doc.xpath('//VINquery/VIN').size == 0
        raise ValidationError
      end

      vin = doc.xpath('//VINquery/VIN').first

      if vin.attributes['Status'].to_s == 'SUCCESS'
        @valid = true
      else
        @valid = false
      end
    end

    def parse(xml)
      doc = Nokogiri::XML xml
      vin = doc.xpath('//VINquery/VIN').first

      if doc.xpath('//VINquery/VIN/Vehicle').size == 0
        raise ParseError
      end

      doc.xpath('//VINquery/VIN/Vehicle').each do |v|
        vehicle = {}

        v.xpath('Item').each do |a|
          key = a.attributes['Key'].to_s.
                                    downcase.
                                    gsub('/', '_').
                                    gsub(' ', '_').
                                    gsub('-', '_').
                                    gsub('.', '').
                                    to_sym

          if a.attributes['Unit'].to_s.length == 0
            vehicle[key] = a.attributes['Value'].to_s
          else
            vehicle[key] = "#{a.attributes['Value'].to_s} #{a.attributes['Unit'].to_s}"
          end
        end

        @trim_levels.push(VinQuery::TrimLevel.new(vin.attributes['Number'].to_s, vehicle))
      end
    end

    def get
      xml = fetch @url

      if validate xml
        parse xml
      end
    end

    private

      def fetch(url)
        Net::HTTP.get(URI.parse(url))
      end
  end
end
