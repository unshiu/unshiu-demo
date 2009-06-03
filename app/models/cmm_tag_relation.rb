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

class CmmTagRelation < ActiveRecord::Base
  include CmmTagRelationModule
end
