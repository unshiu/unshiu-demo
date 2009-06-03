# 
# ポイント管理：ファイルによる一括更新処理
#
require 'fastercsv'

module PntImportWorkerModule
  
  class << self
    def included(base)
      base.class_eval do
        set_worker_name :pnt_import_worker
      end
    end
  end
  
  def import(file_name)
    tmp_path = "#{RAILS_ROOT}/#{AppResources["pnt"]["upload_file_dir"]}" + file_name
    line_number = 0
    success_count = 0
    
    pnt_file_upload_history = PntFileUpdateHistory.new
    pnt_file_upload_history.file_name = file_name
    pnt_file_upload_history.save!
    
    FasterCSV.foreach(tmp_path) do |record|
      line_number += 1
      file_record = PntUploadFileRecord.new(record)
      parser = PntImportRecordParser.new(pnt_file_upload_history.id, line_number, file_record)
     
      next unless parser.entity_user?
      next unless parser.entity_pnt_master?
      next unless parser.add_point?
      
      pnt_point = parser.pnt_point
      PntPoint.transaction do
        pnt_point.save!
        
        pnt_history = PntHistory.new
        pnt_history.pnt_point_id = pnt_point.id
        pnt_history.difference = file_record.point.to_i
        pnt_history.message = file_record.message
        pnt_history.amount = pnt_point.point
        pnt_history.save!
        
        success_count += 1
      end
    end
    
    pnt_file_upload_history.record_count = line_number
    pnt_file_upload_history.success_count = success_count
    pnt_file_upload_history.fail_count = line_number - success_count
    pnt_file_upload_history.complated_at = Time.now
    pnt_file_upload_history.save!
  
    MngMailerNotifier.deliver_pnt_import_finished
      
  rescue Exception => e
    logger.error "import csv error: #{tmp_path}\n #{e}"
  end
  
end

class PntImportRecordParser
  
  attr_accessor :pnt_file_update_hisotry_id, :line_number, :file_record
  attr_accessor :pnt_point
  
  # _param1_:: pnt_file_update_hisotry_id 処理履歴ファイルID
  # _param2_:: line_number 現在処理中の行数 
  # _param3_:: file_record 処理対象
  def initialize(pnt_file_update_hisotry_id, line_number, file_record)
    @pnt_file_update_hisotry_id = pnt_file_update_hisotry_id
    @line_number = line_number
    @file_record = file_record
  end
  
  # ユーザの存在確認
  # 存在していたら trueをかえす。なければエラーレコードを書き込みfalseを返す
  # return  :: boolean 存在しているかどうか
  def entity_user?
    user = BaseUser.find(@file_record.base_user_id.to_i)
    if user.nil?
      error_record = create_error_record
      error_record.reason = "#{I18n.t('view.noun.base_user')}ID#{@file_record.base_user_id}は存在しません。"
      error_record.save
      return false
    end
    # TODO 退会済みだったらはactive?メソッドができたら
    return true
  end
  
  # ポイントマスタの存在確認
  # 存在していたら trueをかえす。なければエラーレコードを書き込みfalseを返す
  # return  :: boolean 存在しているかどうか
  def entity_pnt_master?
    pnt_master = PntMaster.find(@file_record.pnt_master_id.to_i)
    if pnt_master.nil?
      error_record = create_error_record
      error_record.reason = "#{I18n.t('view.noun.pnt_master')}ID#{@file_record.pnt_master_id}は存在しません。"
      error_record.save
      return false
    end
    return true
  end
  
  # ポイント情報の確認
  # ポイントの減算であった場合でもマイナスにならないようならtrue,マイナスになるのならfalseをかえす
  # return  :: boolean 処理可能か
  def add_point?
    @pnt_point = PntPoint.find_or_create_base_user_point(@file_record.pnt_master_id, @file_record.base_user_id)
    @pnt_point.point += @file_record.point.to_i
    
    unless @pnt_point.valid?
      error_record = create_error_record
      error_record.reason = "#{I18n.t('view.noun.pnt_point')}が足りません"
      error_record.save
      return false
    end
    return true
  end
  
  private 
  # PntUpdateErrorRecordを生成する
  # return  :: PntUpdateErrorRecord エラー処理レコードオブジェクト
  def create_error_record
    error_record = PntUpdateErrorRecord.new
    error_record.pnt_file_update_hisotry_id = @pnt_file_update_hisotry_id
    error_record.line_number = @line_number
    error_record.record = @file_record.to_s
    return error_record
  end
end