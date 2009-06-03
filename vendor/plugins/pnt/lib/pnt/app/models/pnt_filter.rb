# == Schema Information
#
# Table name: pnt_filters
#
#  id                   :integer(4)      not null, primary key
#  pnt_master_id        :integer(4)      not null
#  point                :integer(4)      not null
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  deleted_at           :datetime
#  summary              :string(200)
#  pnt_filter_master_id :integer(4)      not null
#  start_at             :datetime
#  end_at               :datetime
#  rule_day             :integer(4)
#  rule_count           :integer(4)
#  stock                :integer(4)
#

module PntFilterModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid

        belongs_to :pnt_master
        belongs_to :pnt_filter_master

        validates_presence_of :summary, :pnt_filter_master_id
        validates_numericality_of :point
        
        validates_date_time :start_at, :end_at, :allow_nil => true, :message => I18n.t('activerecord.errors.messages.invalid')
        
        const_set('NON_LIMIT', -1)
      end
    end
  end
  
  # 初期化処理
  # stockに関しては指定されない場合limitなしを意味する-1に設定
  def initialize(params = nil)
    super
    self.stock = PntFilter::NON_LIMIT if self.stock.nil?
  end

  # 情報取得の際にロックが必要かどうか true だと lockが必要、falseだといらない
  # なおstock値が無限でない場合はfilterの利用にロックが必要
  def use_lock?
    self.stock != PntFilter::NON_LIMIT
  end
  alias has_limit? use_lock? 
  
  # 表示用増減値
  # stockにが合limitなしを意味する-1であれば長さ0の文字列にする
  # return  :: 表示用の増減値
  def show_limit
    self.stock == PntFilter::NON_LIMIT ? '' : self.stock
  end
  
  module ClassMethods
    # 各ポイントマスタごとのfilter情報を返す
    def find_pnt_master_filters(pnt_master_id)
      find(:all, :conditions => [ 'pnt_master_id = ? ', pnt_master_id])
    end
  
    # 処理ターゲットとなるフィルターがあるかどうか検索する
    # ポイントの種別が複数あり、複数かえってくる可能性がある
    def find_target_filters(c_name, a_name)
      find(:all, :joins => :pnt_filter_master,
           :conditions => [ 'controller_name = ? and action_name = ? and (start_at is null or start_at < ?) and (end_at is null or end_at > ?)', c_name, a_name, Time.now, Time.now])
    end
  
    # filter 情報を　for updateをかけてかえす。
    # 成功したらロックをかけたオブジェクトを, 利用できない場合はnilがかえる
    def lock_if_active(pnt_filter_id, point)
     find(:first, 
          :conditions => [ "id = ? and
                           ( stock - ? >= 0 or stock = #{PntFilter::NON_LIMIT} ) and 
                           ( start_at is null or start_at <= ? ) and ( end_at is null or end_at >= ? )", 
                           pnt_filter_id, point, Time.now, Time.now],
          :lock => true)
    end
  end
  
end
