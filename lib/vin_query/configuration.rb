module VinQuery
  module ReportType
    BASIC = 0
    STANDARD = 1
    EXTENDED = 2
    LITE = 3
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.reset
    self.configuration = Configuration.new
  end

  class Configuration
    attr_accessor :url, :access_code, :report_type

    def initialize
      @report_type = ReportType::EXTENDED
    end

    def merge_options(options={})
      options.each do |k, v|
        self.send("#{k}=", v)
      end
    end
  end
end
