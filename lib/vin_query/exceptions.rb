# -*- encoding: utf-8 -*-

module VinQuery
  class Error < StandardError
  end

  class ParseError < Error
  end

  class ValidationError < Error
  end
end
