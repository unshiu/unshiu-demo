# == Schema Information
#
# Table name: base_user_file_histories
#
#  id           :integer(4)      not null, primary key
#  base_user_id :integer(4)      not null
#  file_name    :string(255)     not null
#  complated_at :datetime
#  deleted_at   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

module BaseUserFileHistoryModule
  
  class << self
    def included(base)
      base.class_eval do
        acts_as_paranoid
        belongs_to :base_user
      end
    end
  end
  
  # ランダムなcsvファイル名を生成し、file_nameカラムに設定する
  def create_csv_file_name
    self.file_name = Time.now.strftime("%Y%m%d%H%M%s") + Util.random_string(8) + ".csv"
  end
  
  # 処理が完了しているかどうかを判断する
  # return :: 完了していたらtrue,そうでなければfalse
  def complated?
    !self.complated_at.nil?
  end
  
  # ファイルパスを返す。
  # return :: ファイルパス
  def file_full_path_name
    "#{RAILS_ROOT}/#{AppResources[:base][:user_csv_file_path]}/" + self.file_name
  end
  
  # ダウンロードする際のコンテンツタイプを返す
  # return :: コンテンツタイプ
  def content_type
    ext = File::extname(self.file_name)
    case ext
      when '.csv'
        "text/csv;charset=UTF-8"
    end 
  end
end
