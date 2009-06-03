require File.dirname(__FILE__) + '/../../../test_helper'
require "#{RAILS_ROOT}/lib/workers/mng_user_action_history_archive_create_worker"

module MngUserActionHistoryArchiveCreateWorkerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :mng_user_action_histories
        fixtures :mng_user_action_history_archives
      end
    end
  end
  
  define_method('test: 過去１週間分の履歴ファイルを作成し、対象データは削除する') do 
    
    before_hisotry = MngUserActionHistory.count
    
    assert_difference 'MngUserActionHistoryArchive.count', 1 do 
      worker = MngUserActionHistoryArchiveCreateWorker.new
      worker.generate_file
    end
    
    assert_not_equal(before_hisotry, MngUserActionHistory.count) # 削除されているので履歴数は違う
    
    archive = MngUserActionHistoryArchive.find(:first, :conditions => ['end_datetime = ?', Date.today - 7.days])
    assert File.exist?("#{RAILS_ROOT}/#{AppResources[:mng][:mng_user_action_hitory_archive_file_path]}/#{archive.filename}")
  end
  
end