require 'net/http'
require 'xml'

require 'vin_query/version'
require 'vin_query/vehicle'

class VinQuery
  attr_reader :vehicles, :errors

  def self.get(vin, options={})
    query = VinQuery.new(vin, options)
    query.parse

    return query
  end

  def initialize(vin, options={})
    url = options[:url]
    access_code = options[:access_code]
    report_type = '2' || options[:report_type]

    @vehicles = []
    @errors   = []

    @response = fetch(vin, url, access_code, report_type)
  end

  def valid?
    context = XML::Parser::Context.string(@response)
    doc = XML::Parser.new(context).parse
    vin = doc.find('//VINquery/VIN').first
    if vin && vin.attributes[:Status] == "SUCCESS"
      true
    else
      false
    end
  end

  def parse
    if valid?
      context = XML::Parser::Context.string(@response)
      doc = XML::Parser.new(context).parse
      doc.find('//VINquery/VIN/Vehicle').each do |v|
        vehicle = {}

        v.find('Item').each do |a|
          key = a.attributes['Key'].downcase.
                                    gsub('/', '_').
                                    gsub(' ', '_').
                                    gsub('-', '_').
                                    gsub('.', '').
                                    to_sym

          if a.attributes['Unit'].length < 1
            vehicle[key] = a.attributes['Value']
          else
            vehicle[key] = "#{a.attributes['Value']} #{a.attributes['Unit']}"
          end
        end

        ## Additional attributes: Engine Short Code
        if vehicle[:engine_type]
          vehicle[:engine_short] = vehicle[:engine_type].upcase.match(/([LVH]\d{1,2})/) ? $1 : nil
        end

        @vehicles.push(VinQuery::Vehicle.new(vehicle))
      end
    else
      create_errors
    end
  end

  private

    def fetch(vin, url, access_code, report_type)
      Net::HTTP.get(URI.parse("#{url}?accessCode=#{access_code}&vin=#{vin}&reportType=#{report_type}"))
    end

    def create_errors
      context = XML::Parser::Context.string(@response)
      doc = XML::Parser.new(context).parse
      error = doc.find('//VINquery/VIN/Message').first
      if error
        code = error.attributes[:Key]
        message = error.attributes[:Value]
        @errors << { code: code, message: message }
      else
        @errors << { code: 500, message: '404 Can not find VinQuery XML' }
      end
    end
end