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

module BaseMailTemplateKindModule
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid
        has_many :base_mail_templates
      end
    end
  end
  
end
