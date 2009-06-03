module Forms
  module BaseLoginFormModule
  
    class << self
      def included(base)
        base.class_eval do
          attr_accessor :login, :password

          validates_presence_of :login, :password
        end
      end
    
    end
  end
end