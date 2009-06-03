# == Schema Information
#
# Table name: pnt_masters
#
#  id         :integer(4)      not null, primary key
#  title      :string(200)     default(""), not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  deleted_at :datetime
#

module PntMasterModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid

        validates_presence_of :title

        has_many :pnt_filters
        has_many :pnt_points
      end
    end
  end
  
end
