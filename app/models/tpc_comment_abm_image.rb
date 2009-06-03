# == Schema Information
#
# Table name: tpc_comment_abm_images
#
#  id             :integer(4)      not null, primary key
#  tpc_comment_id :integer(4)      not null
#  abm_image_id   :integer(4)      not null
#  created_at     :datetime
#  updated_at     :datetime
#  deleted_at     :datetime
#

class TpcCommentAbmImage < ActiveRecord::Base
  include TpcCommentAbmImageModule
end
