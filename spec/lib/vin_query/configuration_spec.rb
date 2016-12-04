require 'spec_helper'

describe VinQuery::Configuration do
  before do
    VinQuery.configure do |config|
      config.url = 'http://www.vinquery.com/asdf/asdf.aspx'
      config.access_code = 'asdf1234-asdf1234-asdf1234'
    end
  end

  it 'respects set values in a config block' do
    expect(VinQuery.configuration.url).to eq 'http://www.vinquery.com/asdf/asdf.aspx'
    expect(VinQuery.configuration.access_code).to eq 'asdf1234-asdf1234-asdf1234'
  end

  it 'has a default report type' do
    expect(VinQuery.configuration.report_type).to eq VinQuery::ReportType::EXTENDED
  end

  context 'when manually given options' do
    it 'overrides default configuration settings' do
      VinQuery.configuration.merge_options(report_type: VinQuery::ReportType::LITE)
      expect(VinQuery.configuration.report_type).to eq VinQuery::ReportType::LITE
    end

    it 'overrides previously set configuration settings' do
      VinQuery.configuration.merge_options(access_code: '1234')
      expect(VinQuery.configuration.access_code).to eq '1234'
    end
  end

  after { VinQuery.reset }
end
