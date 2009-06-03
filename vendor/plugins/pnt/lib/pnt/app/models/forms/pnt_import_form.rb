require 'fastercsv'

module Forms
  module PntImportFormModule
  
    class << self
      def included(base)
        base.class_eval do
          attr_accessor :import_file

          validates_presence_of :import_file
        end
      end    
    end
    
    def validate
      return if self.import_file.nil?
      
      filename = Time.now.strftime('%Y%m%d%H%M%S_') + Util.random_string(10)
      tmp_dir = "#{RAILS_ROOT}/#{AppResources["pnt"]["upload_file_dir"]}"
      Dir::mkdir(tmp_dir) unless File.exist?(tmp_dir)
      tmp_path = "#{tmp_dir}#{filename}"
      
      line_count = 0
      FasterCSV.open(tmp_path , "w") do |csv|
        while line = self.import_file.gets
          line_count += 1
          line_arrays = FasterCSV.parse(line)
          record = PntUploadFileRecord.new(line_arrays.flatten)
          if record.valid?
            csv << [record.pnt_master_id,record.base_user_id, record.point, record.message]
          else 
            self.errors.add('file', I18n.t('activerecord.errors.messages.file_record_invalid_format', {:count => line_count}))
            break
          end
        end
      end
    end
  end
end
