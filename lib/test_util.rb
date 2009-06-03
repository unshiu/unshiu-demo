#
# 単体テスト用Utilモジュール
# テストクラスにincludeして利用する
#
# ex)  class Hoge < ActiveSupport::TestCase
#         include TestUtil::Base::PcControllerTest
#      end
#
module TestUtil
  
  module Base
    
    # Gadgetテスト便利モジュール
    module GadgetControllerTest
      
      def setup
        @request.session_options = {:id => "test_session", :key => AppResources[:init][:session_key]}
      end
      
    end
    
    # PCのコントローラテスト便利モジュール
    module PcControllerTest
      include AuthenticatedTestHelper
      
      class << self
        def included(base)
          base.class_eval do
            fixtures :base_errors
          end
        end
      end
      
      def uploaded_file(path, content_type, filename)
        t = Tempfile.new(filename);
        FileUtils.copy_file(path, t.path)
        (class << t; self; end).class_eval do
          alias local_path path
          define_method(:original_filename) {filename}
          define_method(:content_type) {content_type}
        end
        return t
      end
      
      def assert_redirect_with_error_code(error_code)
        error = BaseError.find_by_error_code_use_default(error_code)
        assert_redirected_to :controller => :base, :action => :error, :error_code => error.error_code, :error_message => error.message
      end
      
      def file_path(filename)
        File.expand_path("#{RAILS_ROOT}/test/fixtures/#{filename}")
      end
      
    end

    class ActionController::TestRequest
      attr_accessor :user_agent
    end
  
    # 携帯のコントローラテスト便利モジュール
    # 3キャリアのUser-Agentでテストをまわす
    module MobileControllerTest 
      include AuthenticatedTestHelper
      
      class << self
        def included(base)
          base.class_eval do
            fixtures :base_errors
            fixtures :jpmobile_carriers
            fixtures :jpmobile_devices
          end
        end
      end
      
      def setup
        @request    = ActionController::TestRequest.new
        @response   = ActionController::TestResponse.new
        case @count
        when 0:
          @request.user_agent = 'DoCoMo/2.0 SH903i(c100;TB;W23H16;ser012345678912345;icc012345678912345)'
          @request.env["HTTP_USER_AGENT"] = "DoCoMo/2.0 SH903i(c100;TB;W23H16;ser012345678912345;icc012345678912345)"
          @request.remote_addr = "210.153.84.1"
        when 1:
          @request.user_agent = 'KDDI-SA31 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0'
          @request.env["HTTP_USER_AGENT"] = "KDDI-SA31 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
          @request.env["HTTP_X_UP_SUBNO"] = "012345678912345"
          @request.remote_addr = "61.117.0.128"
        when 2:
          @request.user_agent = 'SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1'
          @request.env["HTTP_USER_AGENT"] = "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
          @request.env["HTTP_X_JPHONE_UID"] = "012345678912345"
          @request.remote_addr = "123.108.236.0"
        end
      end

      def run(result)
        for @count in 0..2
          super
        end
      end

      # FIXME redirect_error_code_asに集約させるのでいらなくなる予定
      def encode(message)
        if @count == 2 # softbankの場合のみ変換しない。
          message
        else
          NKF.nkf('-m0 -x -Ws', message)
        end
      end
      
      def assert_redirect_with_error_code(error_code)
        error = BaseError.find_by_error_code_use_default(error_code)
        assert_redirected_to :controller => :base, :action => :error, :error_code => error.error_code, :error_message => encode(error.message)
      end
      
    end
    
    module UnitTest
      
      def file_path(filename)
        File.expand_path("#{RAILS_ROOT}/test/fixtures/#{filename}")
      end
      
      # テスト用のfixtureデータを読みemailオブジェクトを返す
      # _param1_:: controller名
      # _param2_:: action名
      def read_mail_fixture(controller, action)
        TMail::Mail.load("#{RAILS_ROOT}/test/fixtures/#{controller}/#{action}.txt")
      end
      
    end
    
  end

end
