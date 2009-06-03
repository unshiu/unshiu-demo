# == Schema Information
#
# Table name: base_notices
#
#  id             :integer(4)      not null, primary key
#  title          :string(255)
#  body           :text
#  start_datetime :datetime
#  end_datetime   :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  deleted_at     :datetime
#

module BaseNoticeModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        validates_presence_of :title, :body
        validates_good_word_of :title, :body
        validates_length_of :title, :maximum => AppResources['base']['title_max_length']
        validates_length_of :body, :maximum => AppResources['base']['body_max_length']
        
        validates_date_time :start_datetime, :end_datetime, :message => I18n.t('activerecord.errors.messages.invalid')
      end
    end
  end
  
  def validate
    # 開始時刻が終了時刻より後ならエラー
    if start_datetime && end_datetime
      if start_datetime > end_datetime
        errors.add("start_datetime", "は#{I18n.t('activerecord.attributes.base_notice.end_datetime')}より前の日時を指定してください。")
      end
    end
  end
  
  module ClassMethods
    # 掲載期間なお知らせ
    def current_notices(options = {})
      options.merge!({:conditions => ["start_datetime < ? and end_datetime > ?", Time.now, Time.now], :order => 'start_datetime desc'})
      BaseNotice.find(:all, options)
    end
    
    # すべてのお知らせ
    def all_notices(options = {})
      options.merge!({:order => 'start_datetime desc'})
      BaseNotice.find(:all, options)
    end
  end
end
