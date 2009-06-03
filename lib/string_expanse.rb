class String
  
  def strip_with_full_size_space!
    self.replace(strip_with_full_size_space)
  end
  
  def strip_with_full_size_space
    s = "　\s\v"
    self =~ /^[#{s}]+([^#{s}]+)[#{s}]+$/ ? $1 : self
  end
  
  def to_byte_i
    hits = self.scan(/([0-9]+)(K|M|G|T)$/)
    unless hits.empty?
      case hits.flatten[1]
        when "K"
          hits.flatten[0].to_f * 1024
        when "M"
          hits.flatten[0].to_f * 1024 * 1024
        when "G"
          hits.flatten[0].to_f * 1024 * 1024 * 1024
        when "T"
          hits.flatten[0].to_f * 1024 * 1024 * 1024 * 1024      
      end
    end
  end
end