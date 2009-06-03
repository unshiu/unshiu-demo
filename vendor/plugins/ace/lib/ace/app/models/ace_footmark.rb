# == Schema Information
#
# Table name: ace_footmarks
#
#  id                 :integer(4)      not null, primary key
#  base_user_id       :integer(4)      not null
#  footmarked_user_id :integer(4)      not null
#  place              :string(128)     not null
#  uuid               :string(128)     not null
#  count              :integer(4)      default(0), not null
#  deleted_at         :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

require 'uuidtools'

module AceFootmarkModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        validates_presence_of :uuid, :place, :base_user_id, :footmarked_user_id
        
        belongs_to :base_user
        belongs_to :footmarked_user, :class_name => 'BaseUser', :foreign_key => 'footmarked_user_id'
      end
    end
  end
  
  module ClassMethods
    # メソッドの概要
    # _param1_:: place 
    # _param2_:: base_user_id
    # _param3_:: footmarked_user_id
    # return:: 足跡情報
    def find_footmark(place, base_user_id, footmarked_user_id)
      footmark = find(:first, :conditions => ["place = ? and base_user_id = ? and footmarked_user_id = ? ", place, base_user_id, footmarked_user_id])
      if footmark.nil?
        footmark = self.create({:place => place, :base_user_id => base_user_id, 
                                :footmarked_user_id => footmarked_user_id, :uuid => UUID.random_create().to_s}) 
      end
      return footmark
    end

  end
  
end
