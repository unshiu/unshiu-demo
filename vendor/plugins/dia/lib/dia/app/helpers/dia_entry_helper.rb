module DiaEntryHelperModule
  def removed_array(array, target)
    new_array = array.collect{|image| image.id}
    new_array.delete(target.id)
    new_array.join(',')
  end
end
