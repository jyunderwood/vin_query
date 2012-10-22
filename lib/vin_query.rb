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
    status = doc.find('//VINquery/VIN').first.attributes[:Status]
    if status == "SUCCESS"
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
          key = a.attributes['Key'].downcase.gsub('/', '_').gsub(' ', '_').gsub('-', '_').gsub('.', '').to_sym
          if a.attributes['Unit'].length < 1
            vehicle[key] = a.attributes['Value']
          else
            vehicle[key] = "#{a.attributes['Value']} #{a.attributes['Unit']}"
          end
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
      messages = doc.find('//VINquery/VIN/Message')

      messages.each do |error|
        code = error.attributes[:Key]
        message = error.attributes[:Value]
        @errors << { code: code, message: message }
      end
    end
end