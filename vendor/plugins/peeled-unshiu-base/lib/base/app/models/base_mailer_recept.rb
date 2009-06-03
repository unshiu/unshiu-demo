require 'logger'

module BaseMailerReceptModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  # メールの受信処理
  # _param1_:: TMailによってparseされたメールオブジェクト
  def receive(email)
    log_setup if @logger.nil? 
    @logger.info("[start] mail recept : #{Time.now}")
    
    case email.to.first
    when AppResources[:base][:registration_mail_address]
      base_user = BaseUser.create_temporary_user_from_email(email.from.first)
      if base_user
        if base_user.active? || base_user.forbidden?
          BaseMailerNotifier.deliver_already_registed(base_user, :force)
        else
          BaseMailerNotifier.deliver_send_registration_url(base_user, :force)
        end
      end
      
    when AppResources[:base][:system_mail_address]
      # FIXME 必要性を検討
        
    else
      mail_dispatch(email)
    end
      
  rescue => ex
    @logger.info ex.to_s
    BaseMailerNotifier.deliver_failure_receiving_mail(email)
  end
  
  private 
    
    def log_setup
      @logger= Logger.new("#{RAILS_ROOT}/log/mail_#{RAILS_ENV}.log")
      @logger.level = Logger::INFO
    end
    
    # メールアドレスによって処理の振り分けをする
    def mail_dispatch(email)
      info = BaseMailDispatchInfo.find_by_mail_address(email.to.first)
      unless info
        raise "No matching address."
      end
      user = info.base_user
    
      unless email.from.first == user.email
        raise "Mail address didn't match."
      end

      @logger.info "Call #{info.model_name}.#{info.method_name}."
      Kernel.const_get(info.model_name).method(info.method_name).call(email, info)    
    end
  
end
