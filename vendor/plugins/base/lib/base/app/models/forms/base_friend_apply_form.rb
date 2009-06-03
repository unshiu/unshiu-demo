module Forms
  module BaseFriendApplyFormModule
    class << self
      def included(base)
        base.class_eval do
          attr_accessor :apply_message
           
          validates_presence_of :apply_message
          validates_length_of   :apply_message, :maximum => AppResources[:base][:body_max_length]
          validates_good_word_of :apply_message
        end
      end
    end
  end
end