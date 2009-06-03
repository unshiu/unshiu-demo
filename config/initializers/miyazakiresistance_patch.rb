# メール受信などの場合うまくログの出力先をみつけられないようなので

require 'miyazakiresistance'

module MiyazakiResistance
  module MiyazakiLogger
    def self.included(base)
      base.class_eval do
        @@logger = nil
      end
      base.extend ClassMethods
    end

    module ClassMethods
      def logger
        class_variable_get("@@logger") || (logger = Logger.new("#{RAILS_ROOT}/log/miyazakiresistance.log"))
      end
    end
  end
end