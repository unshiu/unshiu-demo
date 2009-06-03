# == Schema Information
#
# Table name: base_mail_dispatch_infos
#
#  id           :integer(4)      not null, primary key
#  mail_address :string(255)
#  model_name   :string(255)
#  method_name  :string(255)
#  model_id     :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#  base_user_id :integer(4)
#

module BaseMailDispatchInfoModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        belongs_to :base_user
        
        validates_uniqueness_of 'mail_address'
      end
    end
  end
  
  module ClassMethods
    def find_by_dispatch(base_user_id, model_name, method_name, model_id)
      self.find(:first, :conditions => [
        "base_user_id = ? and model_name = ? and method_name = ? and model_id = ?",
      base_user_id, model_name, method_name, model_id])
    end
  end
end
