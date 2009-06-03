# == Schema Information
#
# Table name: base_favorites
#
#  id           :integer(4)      not null, primary key
#  base_user_id :integer(4)      not null
#  favorite_id  :integer(4)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#

class BaseFavorite < ActiveRecord::Base
  include BaseFavoriteModule
end
