module AceHelperModule
  
  def access_log
    base_user_id = current_base_user.nil? ? 0 : current_base_user.id 
    url = CGI::escape(request.env['REQUEST_URI'].gsub(/[?&]#{request.session_options[:session_key]}\=([0-9A-Za-z]*)/, ''))
    "<img src=\"#{AppResources[:ace][:access_log_server]}/img/base_user_id_#{base_user_id}/url_#{url}/acess_log.gif?timestamp=#{Time.now.to_i}\" />"
  end

  def footmark(uuid)
    "<img src=\"#{AppResources[:ace][:access_log_server]}/img/id_#{uuid}/footmark.gif?timestamp=#{Time.now.to_i}\" />"
  end
  
end