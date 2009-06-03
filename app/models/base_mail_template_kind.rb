# == Schema Information
#
# Table name: base_mail_template_kinds
#
#  id          :integer(4)      not null, primary key
#  action      :string(255)     not null
#  name        :string(255)     not null
#  description :string(255)     not null
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class BaseMailTemplateKind < ActiveRecord::Base
  include BaseMailTemplateKindModule  
end
