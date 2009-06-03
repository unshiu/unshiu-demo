module BaseTermsHelperModule
  
  # 利用規約用の内部リンク生成
  def link_terms_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
    options[:activate] = params[:activate]
    options[:invite] = params[:invite]
    link_basic_to(name, options, html_options, parameters_for_method_reference)
  end
  
end