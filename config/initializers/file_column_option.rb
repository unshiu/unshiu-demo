FileColumn::ClassMethods::DEFAULT_OPTIONS[:web_root] = AppResources[:init][:file_column_image_web_root]
FileColumn::ClassMethods::DEFAULT_OPTIONS[:root_path] = File.join(RAILS_ROOT, AppResources[:init][:file_column_image_root_path])
FileColumn::ClassMethods::DEFAULT_OPTIONS[:magick] = {
  :versions => {
    :thumb => {:size => "96x96", :format => "JPG"},
    :large => {:size => "220x220", :format => "JPG"}
  }
}
