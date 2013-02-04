require 'spec_helper'

describe VinQuery do
  describe 'when parsing a valid vin' do
    describe 'when the vin returns multiple trim_levels' do
      before do
        @success_multi = File.read("#{File.dirname(__FILE__)}/fixtures/success_multi.xml")
        FakeWeb.register_uri(:any, %r{http://www.vinquery\.com/}, body: @success_multi)

        @query_with_multi = VinQuery.new('2G1WT57K291223396',
                              url: 'http://www.vinquery.com/asdf/asdf.aspx',
                              access_code: 'asdf1234-asdf1234-asdf1234')
      end

      subject { @query_with_multi }

      it { should respond_to(:valid?) }
      it { should respond_to(:parse) }
      it { should respond_to(:vehicles) }
      it { should respond_to(:errors) }

      it 'should be valid after parse' do
        @query_with_multi.fetch
        @query_with_multi.parse

        @query_with_multi.should be_valid
      end

      it '#parse should increase vehicle count' do
        @query_with_multi.fetch
        @query_with_multi.parse

        @query_with_multi.vehicles.count.should == 4
      end

      describe 'first vehicle' do
        before do
          @query_with_multi.fetch
          @query_with_multi.parse
        end

        subject { @query_with_multi.vehicles.first }

        it { should be_an_instance_of VinQuery::Vehicle }

        it 'has attributes such as make' do
          @query_with_multi.vehicles.first.attributes[:make].should eq 'Nissan'
        end

        it 'has attributes such as model' do
          @query_with_multi.vehicles.first.attributes[:model].should eq 'Sentra'
        end

        it 'has attributes such as trim_level' do
          @query_with_multi.vehicles.first.attributes[:trim_level].should eq '2.0'
        end
      end

      describe 'last vehicle' do
        before do
          @query_with_multi.fetch
          @query_with_multi.parse
        end

        subject { @query_with_multi.vehicles.first }

        it { should be_an_instance_of VinQuery::Vehicle }

        it 'has attributes such as trim_level' do
          @query_with_multi.vehicles.last.attributes[:trim_level].should eq '2.0 SR'
        end
      end
    end

    describe 'when the vin returns a single trim_level' do
      before do
        @success_single = File.read("#{File.dirname(__FILE__)}/fixtures/success_single.xml")
        FakeWeb.register_uri(:any, %r{http://www.vinquery\.com/}, body: @success_single)

        # Note, using #get to fetch and parse in one command
        @query_with_single = VinQuery.get('2G1WT57K291223396',
                              url: 'http://www.vinquery.com/asdf/asdf.aspx',
                              access_code: 'asdf1234-asdf1234-asdf1234')
      end

      subject { @query_with_single }

      it { should be_valid }

      it '#parse should increase vehicle count' do
        @query_with_single.vehicles.count.should == 1
      end
    end
  end

  describe 'when querying an invalid vin' do
    before do
      @error_xml = File.read("#{File.dirname(__FILE__)}/fixtures/error.xml")
      FakeWeb.register_uri(:any, %r{http://www.vinquery\.com/}, body: @error_xml)

      @query_with_error  = VinQuery.new('2G1WT57K291223396',
                                        url: 'http://www.vinquery.com/asdf/asdf.aspx',
                                        access_code: 'asdf1234-asdf1234-asdf1234')
    end

    subject { @query_with_error }

    it 'should not be valid after parse' do
      @query_with_error.fetch
      @query_with_error.parse

      @query_with_error.should_not be_valid
    end

    describe 'when parsing an invalid vin' do
      before do
        @query_with_error.fetch
        @query_with_error.parse
      end

      it 'should increase errors count' do
        @query_with_error.errors.count.should == 1
      end

      it 'should have error message' do
        message = 'Invalid VIN number: This VIN number did not pass checksum test.'
        @query_with_error.errors.first[:message].should == message
      end

      it 'should have 0 vehicles' do
        @query_with_error.vehicles.count.should == 0
      end
    end
  end

  describe 'when can not find a page' do
    before do
      FakeWeb.register_uri(:any, %r{http://www.vinquery\.com/}, body: '<html>404</html>')
      @query_with_404 = VinQuery.new('2G1WT57K291223396',
                                        url: 'http://www.vinquery.com/asdf/asdf.aspx',
                                        access_code: 'asdf1234-asdf1234-asdf1234')
    end

    subject { @query_with_404 }

    it 'should not be valid after parse' do
      @query_with_404.fetch
      @query_with_404.parse

      @query_with_404.should_not be_valid
    end

    describe 'when trying to parse a 404' do
      before do
        @query_with_404.fetch
        @query_with_404.parse
      end

      it 'should increase errors count' do
        @query_with_404.errors.count.should == 1
      end

      it 'should have error message' do
        message = '404 Can not find VinQuery XML'
        @query_with_404.errors.first[:message].should == message
      end

      it 'should have 0 vehicles' do
        @query_with_404.vehicles.count.should == 0
      end
    end
  end
end
