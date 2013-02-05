# -*- encoding: utf-8 -*-
require 'spec_helper'

describe VinQuery::TrimLevel do
  describe '#initialize' do
    let(:trim) { trim = VinQuery::TrimLevel.new('2G1WT57K291223396', {
                                                :model_year => '2009',
                                                :make => 'Chevrolet',
                                                :model => 'Impala',
                                                :trim_level => 'LT' }) }

    it 'have a vin class attribute' do
      expect(trim.vin).to eq '2G1WT57K291223396'
    end

    it 'creates a hash of VinQuery attributes' do
      expect(trim.attributes[:model_year]).to eq '2009'
      expect(trim.attributes[:make]).to eq 'Chevrolet'
      expect(trim.attributes[:model]).to eq 'Impala'
      expect(trim.attributes[:trim_level]).to eq 'LT'
    end

    it 'has a description string of VIN and trim level' do
      expect(trim.to_s).to eq '2G1WT57K291223396 - LT'
    end
  end
end
