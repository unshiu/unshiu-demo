module ManageBaseMailTemplateKindsControllerModule
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  # GET /manage/base_mail_template_kinds
  def index
    list
    render :action => :list
  end
  
  # GET /manage/base_mail_template_kinds
  def list
    @base_mail_template_kinds = BaseMailTemplateKind.find(:all, :order => 'updated_at desc',
                                                         :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]})
  end
  
  # GET /manage/base_mail_template_kind/1
  def show
    @base_mail_template_kind = BaseMailTemplateKind.find(params[:id])
    @active_mail_templates = BaseMailTemplate.find_active_mail_templates_by_action(@base_mail_template_kind.action)
    @draft_mail_templates = BaseMailTemplate.draft_by_action(@base_mail_template_kind.action).find(:all, :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]} )
  end
  
end
