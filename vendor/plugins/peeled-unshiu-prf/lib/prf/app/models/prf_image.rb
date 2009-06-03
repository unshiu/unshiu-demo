# == Schema Information
#
# Table name: prf_images
#
#  id             :integer(4)      not null, primary key
#  prf_profile_id :integer(4)      not null
#  image          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  deleted_at     :datetime
#

module PrfImageModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid
        
        validates_filesize_of :image, :in => 0..AppResources[:prf][:file_size_max_image_size].to_byte_i
        validates_file_format_of :image, :in => AppResources[:prf][:image_allow_format]
        
        file_column :image
      end
    end
  end
  
end
