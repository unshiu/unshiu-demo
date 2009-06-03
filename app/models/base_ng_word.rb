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

class BaseNgWord < ActiveRecord::Base
  include BaseNgWordModule
end
