# == Schema Information
#
# Table name: base_ng_words
#
#  id          :integer(4)      not null, primary key
#  word        :string(255)
#  active_flag :boolean(1)
#  created_at  :datetime
#  updated_at  :datetime
#  deleted_at  :datetime
#

module BaseNgWordModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        cattr_accessor :regular_expression
        
        validates_presence_of   :word
        validates_uniqueness_of :word
      end
    end
  end
  
  def active_str
   (active_flag)? '有効' : '無効'
  end
  
  def after_save
    self.class.regular_expression = Regexp.union(*self.class.active_words)
  end
  
  module ClassMethods
    def active_words
      find(:all, :conditions => 'active_flag = true').collect{|r| r.word}
    end
    
    def regexp
      if self.regular_expression
        self.regular_expression
      else
        self.regular_expression = Regexp.union(*active_words)
      end
    end
  end
end
