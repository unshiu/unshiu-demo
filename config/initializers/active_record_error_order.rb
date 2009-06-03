# validationエラー時の順番をvalidation順にそろえる
module ActiveSupport
  class OrderedHash
    def each_key
      each { |key, value| yield key }
    end
  end
end

module ActiveRecord
  class Errors
    def initialize(base) # :nodoc:
      @base, @errors = base, ActiveSupport::OrderedHash.new
    end

    def clear
      @errors = ActiveSupport::OrderedHash.new
    end
  end
end