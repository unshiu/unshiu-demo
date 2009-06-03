require File.dirname(__FILE__) + '/../test_helper'

module BaseMailTemplateTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_mail_templates
        fixtures :base_mail_template_kinds
      end
    end
  end
  
  define_method('test: find_active_mail_templates_by_action は指定アクションの対象テンプレートを取得する') do 
    base_mail_templates = BaseMailTemplate.find_active_mail_templates_by_action('send_registration_url')
    
    assert_not_nil base_mail_templates
    assert(base_mail_templates.size > 0)
    
    base_mail_templates.each do |base_mail_template|
      assert_equal(base_mail_template.active_flag, true) # 有効である
    end
  end

  define_method('test: find_active_mail_templates_by_action は指定アクションがDBになければ空の配列がかえる') do 
    base_mail_templates = BaseMailTemplate.find_active_mail_templates_by_action('xxxxx_xxxxx')
    
    assert_not_nil base_mail_templates
    assert_equal(base_mail_templates.size, 0)
  end
  
  define_method('test: find_active_mail_templates_by_template_kind_id は指定種別IDの有効なテンプレートを取得する') do 
    base_mail_templates = BaseMailTemplate.find_active_mail_templates_by_template_kind_id(1)
    
    assert_not_nil base_mail_templates
    assert(base_mail_templates.size > 0)
    
    base_mail_templates.each do |base_mail_template|
      assert_equal(base_mail_template.active_flag, true) # 有効である
    end
  end
  
  define_method('test: 利用可能なメールタイプを取得する') do 
    assert_not_nil BaseMailTemplate.content_types
  end
  
  define_method('test: device_types は利用可能なデバイスタイプを取得する') do 
     divice_types = BaseMailTemplate.device_types
     assert_not_nil divice_types
     assert_equal(divice_types.size, 2)
   end
   
  define_method('test: 利用可能なメールタイプをユーザにわかりやすい形式で表示する取得する') do 
    base_mail_template = BaseMailTemplate.new
    base_mail_template.content_type = "text/plain"
    
    assert_equal base_mail_template.view_content_type, "テキストメール"
  end
  
  define_method('test: footerを利用するかどうか判断する') do 
    base_mail_template = BaseMailTemplate.new
    base_mail_template.footer_flag = true
    assert_equal(base_mail_template.footer?, true)

    base_mail_template.footer_flag = false
    assert_equal(base_mail_template.footer?, false)
  end
  
  define_method('test: 現在利用テンプレートとして有効化されているかどうか判断する') do 
    base_mail_template = BaseMailTemplate.new
    base_mail_template.active_flag = true
    assert_equal(base_mail_template.active?, true)

    base_mail_template.active_flag = false
    assert_equal(base_mail_template.active?, false)
  end
  
  define_method('test: view_device_type は利用可能な表示用のデバイスタイプ値取得する') do 
     base_mail_template = BaseMailTemplate.new
     base_mail_template.device_type = 2
     
     assert_not_nil base_mail_template.view_device_type
     assert_equal(base_mail_template.view_device_type, "PC用")
  end
  
  define_method('test: draft_by_action は指定アクションの下書きで有効でないテンプレート一覧を取得する') do 
    template = BaseMailTemplate.new({:base_mail_template_kind_id => 2, :content_type => "text/plain", 
                                     :subject => "test", :body => "test", :active_flag => false, :footer_flag => false, :device_type => 1})
    template.save
    
    mail_templates = BaseMailTemplate.draft_by_action("send_registration_url")
    
    assert_not_nil(mail_templates)
    assert(mail_templates.size > 0)
    
    mail_templates.each do |mail_template|
      assert_equal(mail_template.active_flag, false) # 無効
    end
  end
  
  define_method('test: find_active_mail_template_by_action_name_and_device_type は指定アクションの指定送信先で有効でないテンプレートを取得する') do 
    template = BaseMailTemplate.find_active_mail_template_by_action_name_and_device_type("send_registration_url", 1)
    assert_not_nil(template)
    assert_equal(template.base_mail_template_kind_id, 2)
    assert_equal(template.device_type, 1)
  end
  
  define_method('test: find_active_mail_template_by_template_kind_id_and_device_type は指定アクションの指定送信先で有効でないテンプレートを取得する') do 
    template = BaseMailTemplate.find_active_mail_template_by_template_kind_id_and_device_type(1, 1)
    assert_not_nil(template)
    assert_equal(template.base_mail_template_kind_id, 1)
    assert_equal(template.device_type, 1)
  end
  
end
