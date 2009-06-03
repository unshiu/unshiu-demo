# == Schema Information
#
# Table name: mlg_magazines
#
#  id         :integer(4)      not null, primary key
#  title      :string(500)     default(""), not null
#  body       :string(2000)    default(""), not null
#  send_at    :datetime
#  sended_at  :datetime
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  deleted_at :datetime
#

class MlgMagazine < ActiveRecord::Base
  include MlgMagazineModule
end
