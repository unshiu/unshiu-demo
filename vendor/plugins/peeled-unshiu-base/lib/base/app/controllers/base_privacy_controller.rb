module BasePrivacyControllerModule
  class << self
    def included(base)
      base.class_eval do
        nested_layout_with_done_layout
      end
    end
  end
end
