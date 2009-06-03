# == Schema Information
#
# Table name: cmm_tag_relations
#
#  id                :integer(4)      not null, primary key
#  cmm_tag_id        :integer(4)
#  parent_cmm_tag_id :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#

module CmmTagRelationModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid
      end
    end
  end
  
end
