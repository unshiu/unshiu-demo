
######################################################################
### Auto Nested Layout
ActionController::Base.class_eval do
  #class_inheritable_array :nested_layouts
  #self.nested_layouts = [] コメントアウト

  class << self
    def nested_layout(files = ['application'], options = {})
      #find_filter(:render_with_nested_layouts) or
      #  after_filter :render_with_nested_layouts
      # 以下、いろいろ変更
      files = ['application'] unless files
      if files.blank?
        files << 'layouts/application'
      else
        files[0] = 'layouts/' + files[0]
      end
      #self.nested_layouts = files
      layout false
      
      filter = NestedLayoutFilter.new
      filter.layouts = files
      filter.layouts_mobile = files.collect{|layout| layout + '_mobile'}
      
      around_filter filter, options
        # around_filter に変更　jpmobile との関係での文字化けに対応
        # options 追加
    end
  end
  
  # private 外した
  def render_with_nested_layouts(layouts)
    return true if guard_from_nested_layouts

    if layouts.size <= 1
      guess_layouts = guess_nested_layouts
      guess_layouts.collect!{|layout| layout + '_mobile'} if request.mobile?
      layouts.concat(guess_layouts)
      layouts.reverse!
    end

    logger.debug "Rendering nested layouts %s" % layouts.inspect
    
    layouts.each do |layout|
      content_for_layout = response.body
      erase_render_results
      @template.instance_variable_set("@content_for_layout", content_for_layout)
      render :partial => layout
    end

#    content_for_layout = response.body
#    erase_render_results
#    add_variables_to_assigns
#    @template.instance_variable_set("@content_for_layout", content_for_layout)
#    render :text => @template.render_file("layouts/application", true)
  end
      
  private

  def guard_from_nested_layouts
    return true if @before_filter_chain_aborted
    return true if @performed_redirect
    return true if request.xhr?
    return true if !action_has_layout?
    return false
  end

  def guess_nested_layouts
    layouts      = [Pathname("/")]
    partial_path = controller_path.split('/')
    
    controller_path.split('/').each{|dir| layouts << layouts.last + dir unless dir.to_s == "." }
    
    if request.mobile?
      layouts.reject!{|path| !(Pathname(RAILS_ROOT) + "app/views#{path}" + "_layout_mobile.html.erb").exist? }
    else
      layouts.reject!{|path| !(Pathname(RAILS_ROOT) + "app/views#{path}" + "_layout.html.erb").exist? }
    end
    return layouts.reverse.map{|i| (i+"layout").to_s}
  end

  # 追加
  class NestedLayoutFilter
    attr_accessor :layouts, :layouts_mobile
    
    def before(controller)
      controller.class.layout false
      return
    end
    
    def after(controller)
      if controller.request.mobile?
        controller.render_with_nested_layouts(layouts_mobile)
      else
        controller.render_with_nested_layouts(layouts)
      end
    end
  end
end

