# -*- encoding: utf-8 -*-
require 'spec_helper'

describe VinQuery::Query do

  let(:client) { VinQuery::Query.new('2G1WT57K291223396',
                                     :url => 'http://www.vinquery.com/asdf/asdf.aspx',
                                     :access_code => 'asdf1234-asdf1234-asdf1234') }

  let(:xml_error)  { File.read(File.join('spec', 'fixtures', 'error.xml')) }
  let(:xml_multi)  { File.read(File.join('spec', 'fixtures', 'success_multi.xml')) }
  let(:xml_single) { File.read(File.join('spec', 'fixtures', 'success_single.xml')) }

  describe '#initialize' do
    it 'stores the complete URL of the VinQuery request (with default report type)' do
      expect(client.url).to eq "http://www.vinquery.com/asdf/asdf.aspx?accessCode=asdf1234-asdf1234-asdf1234&vin=2G1WT57K291223396&reportType=2"
    end

    it 'creates an empty array of trim levels' do
      expect(client.trim_levels).to eq []
    end
  end

  describe '#validate' do
    context 'when response is successful' do
      it 'is valid' do
        client.validate xml_single
        expect(client.valid?).to eq true
      end
    end

    context 'when response is an error' do
      it 'is not valid' do
        client.validate xml_error
        expect(client.valid?).to eq false
      end
    end
  end

  describe '#parse' do
    context 'when a single trim level is returned' do
      before(:each) { client.parse xml_single }

      it 'populates an array of trim levels with 1 trim level' do
        expect(client.trim_levels.size).to be 1
      end

      it 'has an array of VinQuery::TrimLevel objects' do
        expect(client.trim_levels.first).to be_an_instance_of VinQuery::TrimLevel
      end

      it 'has a trim level with vin and VinQuery attributes' do
        expect(client.trim_levels.first.vin).to eq '2G1WT57K291223396'

        expect(client.trim_levels.first.attributes[:model_year]).to eq '2009'
        expect(client.trim_levels.first.attributes[:make]).to eq 'Chevrolet'
        expect(client.trim_levels.first.attributes[:model]).to eq 'Impala'
      end

      it 'has a trim level with units appended to attributes if units are given' do
        expect(client.trim_levels.first.attributes[:tank]).to eq '17.00 gallon'
      end
    end

    context 'when multiple trim levels are returned' do
      before(:each) { client.parse xml_multi }

      it 'populates an array of trim levels with the number of trim levels' do
        expect(client.trim_levels.size).to be 4
      end

      it 'has an array of VinQuery::TrimLevel objects' do
        expect(client.trim_levels.first).to be_an_instance_of VinQuery::TrimLevel
      end

      it 'has the correct first trim level from xml' do
        expect(client.trim_levels.first.attributes[:make]).to eq 'Nissan'
        expect(client.trim_levels.first.attributes[:model]).to eq 'Sentra'
        expect(client.trim_levels.first.attributes[:trim_level]).to eq '2.0'
      end

      it 'has the correct last trim level from xml' do
        expect(client.trim_levels.last.attributes[:make]).to eq 'Nissan'
        expect(client.trim_levels.last.attributes[:model]).to eq 'Sentra'
        expect(client.trim_levels.last.attributes[:trim_level]).to eq '2.0 SR'
      end
    end

    context 'when error is returned' do
      it 'raises a VinQuery::ParseError' do
        expect{ client.parse(xml_error) }.to raise_error VinQuery::ParseError
      end
    end
  end

  describe '#get' do
    context 'success response' do
      before(:each) do
        client.stub(:fetch).and_return xml_multi
        client.get
      end

      it 'fetches xml and response is valid' do
        expect(client.valid?).to be true
      end

      it 'has 0 trim levels' do
        expect(client.trim_levels.size).to eq 4
      end
    end

    context 'error response' do
      before(:each) do
        client.stub(:fetch).and_return xml_error
        client.get
      end

      it 'fetches xml and response is not valid' do
        expect(client.valid?).to be false
      end

      it 'has 0 trim levels' do
        expect(client.trim_levels.size).to eq 0
      end
    end

    context '404 response' do
      before(:each) { client.stub(:fetch).and_return '<html>404</html>' }

      it 'fetches xml and response cannot be validated' do
        expect{ client.get }.to raise_error VinQuery::ValidationError
      end
    end
  end
end
