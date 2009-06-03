module ManageBaseMailTemplatesControllerModule
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  # GET /manage/base_mail_templates
  def index
    @base_mail_templates = BaseMailTemplate.find(:all, :order => 'updated_at desc',
                                                 :page => {:size => AppResources["mng"]["standard_list_size"], :current => params[:page]})
  end

  # GET /manage/base_mail_templates/1
  def show
    @base_mail_template = BaseMailTemplate.find(params[:id])
    @forms_base_mail_template_send_test_form = Forms::BaseMailTemplateSendTestForm.new
  end

  # GET /manage/base_mail_templates/new
  def new
    @base_mail_template = BaseMailTemplate.new
    @base_mail_template.base_mail_template_kind_id = params[:kind_id] if params[:kind_id]
    @base_mail_template_kinds = BaseMailTemplateKind.find(:all)
  end

  # GET /manage/base_mail_templates/1/edit
  def edit
    @base_mail_template = BaseMailTemplate.find(params[:id])
    @base_mail_template_kinds = BaseMailTemplateKind.find(:all)
  end
  
  def create_confirm
    @base_mail_template = BaseMailTemplate.new(params[:base_mail_template])
    @base_mail_template.active_flag = false # 初期作成時は無効
    @base_mail_template_kind = BaseMailTemplateKind.find(@base_mail_template.base_mail_template_kind_id)
    
    unless @base_mail_template.valid?
      @base_mail_template_kinds = BaseMailTemplateKind.find(:all)
      render :action => 'new'
      return
    end
  end
  
  def update_confirm
    @base_mail_template = BaseMailTemplate.find(params[:id])
    @base_mail_template.attributes = params[:base_mail_template]
    @base_mail_template_kind = BaseMailTemplateKind.find(@base_mail_template.base_mail_template_kind_id)
    
    unless @base_mail_template.valid?
      @base_mail_template_kinds = BaseMailTemplateKind.find(:all)
      render :action => 'new'
      return
    end
  end
  
  def active_confirm
    @base_mail_template = BaseMailTemplate.find(params[:id])
    @base_mail_template_kind = BaseMailTemplateKind.find(@base_mail_template.base_mail_template_kind_id)
  end
  
  def destroy_confirm
    @base_mail_template = BaseMailTemplate.find(params[:id])
    @base_mail_template_kind = BaseMailTemplateKind.find(@base_mail_template.base_mail_template_kind_id)
  end
  
  # POST /manage/base_mail_templates
  def create
    @base_mail_template = BaseMailTemplate.new(params[:base_mail_template])
    @base_mail_template.active_flag = false
    
    if cancel?
      @base_mail_template_kinds = BaseMailTemplateKind.find(:all)
      render :action => "new" 
      return 
    end
    
    if @base_mail_template.save
      flash[:notice] = t('view.flash.notice.base_mail_template_create')
      redirect_to manage_base_mail_template_path(@base_mail_template)
    else
      @base_mail_template_kinds = BaseMailTemplateKind.find(:all)
      render :action => "new" 
    end
  end

  # PUT /manage/base_mail_templates/1
  def update
    @base_mail_template = BaseMailTemplate.find(params[:id])

    if cancel?
      @base_mail_template_kinds = BaseMailTemplateKind.find(:all)
      render :action => "edit"
      return
    end
    
    active_template = BaseMailTemplate.find_active_mail_template_by_template_kind_id_and_device_type(@base_mail_template.base_mail_template_kind_id, params[:base_mail_template][:device_type])
    if !active_template.nil? && @base_mail_template.active_flag
      active_template.active_flag = false
      active_template.save!
    end
    
    @base_mail_template.update_attributes(params[:base_mail_template])
    
    flash[:notice] = t('view.flash.notice.base_mail_template_update')
    redirect_to manage_base_mail_template_path(@base_mail_template)
  end

  # PUT /manage/base_mail_templates/1
  def active
    @base_mail_template = BaseMailTemplate.find(params[:id])
    
    if cancel?
      redirect_to(manage_base_mail_template_kind_path(@base_mail_template.base_mail_template_kind_id))
      return 
    end
    
    active_templates = BaseMailTemplate.find_active_mail_templates_by_template_kind_id(@base_mail_template.base_mail_template_kind_id)
    active_templates.each do |active_template|
      if active_template.device_type == @base_mail_template.device_type
        active_template.active_flag = false 
        active_template.save
      end
    end
    @base_mail_template.active_flag = true
    @base_mail_template.save
    
    flash[:notice] = t('view.flash.notice.base_mail_template_active')
    redirect_to manage_base_mail_template_kind_path(@base_mail_template.base_mail_template_kind_id)
  end
  
  # DELETE /manage/base_mail_templates/1
  def destroy
    @base_mail_template = BaseMailTemplate.find(params[:id])

    if cancel?
      redirect_to(manage_base_mail_template_kind_path(@base_mail_template.base_mail_template_kind_id))
      return 
    end
    
    @base_mail_template.destroy

    flash[:notice] = t('view.flash.notice.base_mail_template_destroy')
    redirect_to(manage_base_mail_template_kind_path(@base_mail_template.base_mail_template_kind_id))
  end
  
  # テスト送信処理
  def send_test_confirm
    @base_mail_template = BaseMailTemplate.find(params[:id])
    @forms_base_mail_template_send_test_form = Forms::BaseMailTemplateSendTestForm.new(params[:forms_base_mail_template_send_test_form])
    unless @forms_base_mail_template_send_test_form.valid?
      render :action => "show"
      return 
    end
    @base_mail_template_kind = BaseMailTemplateKind.find(@base_mail_template.base_mail_template_kind_id)
  end
  
  # テスト送信実行
  def send_test
    @forms_base_mail_template_send_test_form = Forms::BaseMailTemplateSendTestForm.new(params[:forms_base_mail_template_send_test_form])
    @base_mail_template = BaseMailTemplate.find(params[:id])
    
    if cancel?
      render :action => "show" 
      return 
    end
    
    BaseMailerNotifier.send("deliver_send_test_#{@base_mail_template.base_mail_template_kind.action}", 
                            @base_mail_template, @forms_base_mail_template_send_test_form.mail_address, :force)
    
    flash[:notice] = "「#{@forms_base_mail_template_send_test_form.mail_address}」宛に送信しました"
    redirect_to(manage_base_mail_template_kind_path(@base_mail_template.base_mail_template_kind_id))
  end
end
