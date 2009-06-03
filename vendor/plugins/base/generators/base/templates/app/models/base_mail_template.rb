# == Schema Information
#
# Table name: base_mail_templates
#
#  id                         :integer(4)      not null, primary key
#  base_mail_template_kind_id :integer(4)      not null
#  content_type               :string(255)     not null
#  subject                    :string(255)     not null
#  body                       :text            default(""), not null
#  active_flag                :boolean(1)
#  footer_flag                :boolean(1)
#  deleted_at                 :datetime
#  created_at                 :datetime
#  updated_at                 :datetime
#

class BaseMailTemplate < ActiveRecord::Base
  include BaseMailTemplateModule
end
