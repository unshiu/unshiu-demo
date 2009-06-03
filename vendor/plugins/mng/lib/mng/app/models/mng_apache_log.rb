#
# Mng:Apacheのアクセスログクラス
#
module MngApacheLogModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        attr_accessor :filename, :mtime, :filesize
      end
    end
  end
  
  def initialize(filename, mtime, filesize)
    self.filename = filename
    self.mtime = mtime
    self.filesize = filesize
  end
  
  module ClassMethods
  
    def find_all
      result = []
      Dir::glob("#{AppResources[:mng][:apache_log_dir]}/*").each do |file|
        result << MngApacheLog.new(File.basename(file), File.mtime(file), File::stat(file).size)
      end
      result
    end

  end
  
end