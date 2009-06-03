# == Schema Information
#
# Table name: base_inquires
#
#  id           :integer(4)      not null, primary key
#  title        :string(255)
#  body         :text
#  referer      :string(255)
#  mail_address :string(255)
#  base_user_id :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#

module BaseInquireModule
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid
        belongs_to :base_user
        
        validates_length_of :body, :maximum => AppResources['base']['body_max_length']
        validates_presence_of :body, :mail_address
        validates_legal_mail_address_of :mail_address
      end
    end
  end
end
