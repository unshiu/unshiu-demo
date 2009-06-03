require File.dirname(__FILE__) + '/../../test_helper'

module Script
  module MlgDelivererTestModule
    
    class << self
      def included(base)
        base.class_eval do
          fixtures :base_users
          fixtures :mlg_magazines
          fixtures :mlg_deliveries
        end
      end
    end
  
    # 配達処理をするworkerのテスト
    # 細かい処理はアクセルメールがやってくれるのでアクセルメール宛に送る
    def test_mlg_deliverer
    
      # --- 送信処理実行　--- #
      # なぜか出力をリダイレクトしないと失敗する
      # Windows でも動くように書き換えてみた
      # FIXME mac だと動かない？すべての platform で動かすのは大変だ。。。
      assert_equal(system("ruby script/mlg_deliverer.rb RAILS_ENV=test > /dev/null"), true)
    
      # テスト後確認事項
      magazine = MlgMagazine.find(1)
      assert_not_nil magazine.sended_at  # 配達済み
    
      derivery = MlgDelivery.find(:all, :conditions => [' mlg_magazine_id = 1 and sended_at is null '])
      assert_equal(derivery.size, 0) # 全員配達済み
    
    end
  
  end
end
