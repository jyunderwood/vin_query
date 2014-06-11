require 'net/http'
require 'nokogiri'

module VinQuery
  class Query
    attr_reader :vin, :url, :trim_levels

    def initialize(vin, options={})
      VinQuery.configuration.merge_options(options)
      @vin = vin
      @trim_levels = []
      build_url
    end

    def valid?
      @valid
    end

    def validate(xml)
      doc = Nokogiri::XML(xml)
      raise ValidationError if doc.xpath('//VINquery/VIN').size == 0

      results_vin = doc.xpath('//VINquery/VIN').first
      if results_vin.attributes['Status'].to_s == 'SUCCESS'
        @valid = true
      else
        @valid = false
      end
    end

    def parse(xml)
      doc = Nokogiri::XML(xml)
      raise ParseError if doc.xpath('//VINquery/VIN/Vehicle').size == 0

      results_vin = doc.xpath('//VINquery/VIN').first
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

        @trim_levels.push(VinQuery::TrimLevel.new(results_vin.attributes['Number'].to_s, vehicle))
      end
    end

    def get
      xml = fetch(@url)
      parse(xml) if validate(xml)
    end

    private

      def build_url
        url = VinQuery.configuration.url
        access_code = VinQuery.configuration.access_code
        report_type = VinQuery.configuration.report_type

        @url = "#{url}?accessCode=#{access_code}&vin=#{vin}&reportType=#{report_type}"
      end

      def fetch(url)
        Net::HTTP.get(URI.parse(url))
      end
  end
end
