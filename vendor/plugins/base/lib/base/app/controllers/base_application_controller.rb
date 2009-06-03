module BaseApplicationControllerModule
  
  class << self
    def included(base)
      base.class_eval do
        before_filter :redirect_unavailable_mobile
        
        # エラー処理
        unless consider_all_requests_local
          # 404 エラーにするエラークラスたち
          const_set('NOT_FOUND_ERRORS',[::ActiveRecord::RecordNotFound, ::ActionController::UnknownController,
          ::ActionController::UnknownAction, ::ActionController::RoutingError, ActionView::ActionViewError])
          
          # エラー処理を行うメソッド
          # 可能ならば base/error(redirect_to_error) を使ってエラーを表示しログイン状態を保持する
          # エラーページでさらにこけるようなら、public/404.html, 500.html(携帯なら _mobile つき)を表示する
          # それでもこけたら super まかせ(携帯/PC の区別なく PC 版のエラーページになる)
          # ただし、PC かつ 404 エラーなら最初から 404.html を表示する
          def rescue_action_in_public(exception)
            #エラーメールを送信
            unless exception.class == ::ActionController::RoutingError || exception.class == ActionView::ActionViewError
              deliverer = self.class.exception_data
              data = case deliverer
                when nil then {}
                when Symbol then send(deliverer)
                when Proc then deliverer.call(self)
              end
              ExceptionNotifier.deliver_exception_notification(exception, self, request, data)
            end
            
            if controller_name == 'base' && action_name == 'error' ||
              !request.mobile? && NOT_FOUND_ERRORS.include?(exception.class)
              # 携帯なら _mobile つきを選択する
              if request.mobile?
                suffix = '_mobile'
              else
                suffix = ''
              end
              
              # 表示する text の選択/取得
              if NOT_FOUND_ERRORS.include?(exception.class)
                text = IO.read(File.join(RAILS_ROOT, 'public', "404#{suffix}.html"))
              else
                text = IO.read(File.join(RAILS_ROOT, 'public', "500#{suffix}.html"))
              end
              
              # Shift_JIS 対応
              if response.charset == 'Shift_JIS'
                text = NKF.nkf('-m0 -x -Ws', text)
              end
              
              render :text => text
              return
            end
            
            if NOT_FOUND_ERRORS.include?(exception.class)
              # 404 notfound
              redirect_to_error("U-00001")
            else
              # 500 error
              redirect_to_error("U-00002")
            end
          rescue
            super
          end
          
          def local_request?
            false
          end
        end
      end
    end
  end

private
  
  # エラーページにリダイレクトしてメッセージと、「戻る」リンクを表示します
  # _error_code_:: エラーコード
  # _next_url_:: 「戻る」リンク先。nil ならリンクを表示しない
  def redirect_to_error(error_code, next_url = nil)
    # TODO 応急処置でとりあえずここで error_message を SJIS に変換している
    #      ただし、文字コードが UTF8 な携帯（Vodafone 3G or Softbank）の場合は、変換しない
    #      redirect_to 全体に汎用化したい
    error = BaseError.find_by_error_code_use_default(error_code)
    mobile = request.mobile
    apply_encode = mobile && !(mobile.instance_of?(Jpmobile::Mobile::Vodafone)||mobile.instance_of?(Jpmobile::Mobile::Softbank))
    if apply_encode
      redirect_to :controller => '/base', :action => 'error',
                  :error_code => error.error_code, :error_message => NKF.nkf('-m0 -x -Ws', error.message), :next_url => next_url
    else
      redirect_to :controller => '/base', :action => 'error',
                  :error_code => error.error_code, :error_message => error.message, :next_url => next_url      
    end
  end

  # email情報を元にキャリア情報を更新する
  def setup_carrier(user)
    base_carrier = base_carrier_by_user(user)
    
    user = BaseUser.find(user.id)
    user.base_carrier_id = base_carrier.id
    user.save
    
    if request.mobile? # UserAgent から端末名を取得して記録する
      device_name = request.mobile.device_name
      if device_name && user.device_name != device_name
        user.device_name = device_name
        user.save
      end
    end
  end
  
  # キャリア情報を取得する
  # _param1_:: user ユーザ情報
  def base_carrier_by_user(user)
    carrier_obj = Jpmobile::Email.detect(user.email)
    base_carrier = BaseCarrier.find_by_carrier(carrier_obj)
    if base_carrier.nil?
      base_carrier = BaseCarrier.new
      base_carrier.carrier = carrier_obj
      base_carrier.save
    end
    base_carrier
  end
  
  # 携帯で閲覧可能か機種の判別処理を行う
  # UserAgentで携帯と判別される場合か、携帯の領域からのアクセスの場合に判別対象とする。
  # 禁止されている端末の場合、静的な別ページを表示させる
  def redirect_unavailable_mobile
    if request.mobile? || (request.mobile != nil && request.mobile.valid_ip?) 
      unless request.available_device?
        text = IO.read(File.join(RAILS_ROOT, 'public', "unavailable_mobile.html"))
        text = NKF.nkf('-m0 -x -Ws', text) if response.charset == 'Shift_JIS'
        render :text => text
      end
    end
  end
    
end
