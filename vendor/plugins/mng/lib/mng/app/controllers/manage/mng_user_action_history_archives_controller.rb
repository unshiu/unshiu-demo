module ManageMngUserActionHistoryArchivesControllerModule
  
  # GET /manage/mng_user_action_history_archives
  def index
    @mng_user_action_history_archives = MngUserActionHistoryArchive.find(:all, :order => 'created_at desc',
                                                                         :page => {:size => AppResources[:mng][:standard_list_size], :current => params[:page]})
  end

  def download
    archive = MngUserActionHistoryArchive.find(params[:id])
    path = "#{RAILS_ROOT}/#{AppResources[:mng][:mng_user_action_hitory_archive_file_path]}/#{archive.filename}"

    send_file path, :filename => "#{archive.filename}"
  end
  
end