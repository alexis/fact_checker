# encoding: utf-8

module FactChecker
  class Result
    def initialize(pre_res, req_res)
      @pre_res = pre_res
      @req_res = req_res
    end

    def valid?
      @pre_res && @req_res
    end

    def available?
      @pre_res
    end
  end
end
