# == Schema Information
#
# Table name: abm_images
#
#  id                :integer(4)      not null, primary key
#  abm_album_id      :integer(4)      not null
#  title             :string(255)
#  body              :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#  image             :string(255)
#  image_size        :integer(4)      not null
#  original_filename :string(255)     not null
#  content_type      :string(255)     not null
#

require 'mime/types'

module AbmImageModule 
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        belongs_to :abm_album
        has_many :abm_image_comments, :dependent => :destroy
        
        # FIXME これでは仕様が不明確
        validates_length_of :title, :maximum => AppResources['base']['title_max_length'], :if => :title # 変な文だが、nil だと invalid になるので対策
        validates_length_of :body, :maximum => AppResources['base']['body_max_length'], :if => :body # 変な文だが、nil だと invalid になるので対策
        validates_presence_of :title, :image, :image_size, :original_filename, :content_type
        validates_good_word_of :title
        
        validates_filesize_of :image, :in => 0..AppResources[:abm][:file_size_max_image_size].to_byte_i
        validates_file_format_of :image, :in => AppResources[:abm][:image_allow_format]
        file_column :image
        
        named_scope :public_all, :include => [:abm_album], :conditions => ['abm_albums.public_level = ? ', UserRelationSystem::PUBLIC_LEVEL_ALL]
      end
    end
  end
  
  def mine?(base_user_id)
    self.abm_album.base_user_id == base_user_id
  end
  
  # 同じアルバム内で次の画像を返す。
  def next
    self.class.find(:first, :conditions => ["abm_album_id = ? and id > ?", self.abm_album_id, self.id], :order => "id")
  end
  
  # 同じアルバム内で次の画像を指定数分取得する。
  # _param1_:: limit
  def nexts(limit)
    self.class.find(:all, :conditions => ["abm_album_id = ? and id > ?", self.abm_album_id, self.id], :order => "id", :limit => limit)
  end
  
  # 同じアルバム内で前の画像を返す。
  def previous
    image = AbmImage.find(:first,
      :conditions => ["abm_album_id = ? and id < ?", self.abm_album_id, self.id], :order => "id desc")

    image
  end
  
  # 同じアルバム内で前の画像を指定数分取得する。
  # _param1_:: limit
  def previouses(limit)
    self.class.find(:all, :conditions => ["abm_album_id = ? and id < ?", self.abm_album_id, self.id], :order => "id desc", :limit => limit)
  end

  # swfuploadからアップロードされたファイルデータを解析しabm_image要素を設定する
  # _param1_:: file_data
  def swfupload_file=(data)
    self.title = data.original_filename
    self.content_type = MIME::Types.type_for(data.original_filename).to_s
    self.original_filename = data.original_filename
    self.image_size = data.size
    self.image = data
  end
  
  alias :upload_file= :swfupload_file=
  
  module ClassMethods
    
    # 指定keywordをタイトルか本文に持つ画像一覧を取得する。キーワードが指定されていなければ全体を取得する。
    # FIXME 全文検索エンジン対応
    # _param1_:: keyword
    # return:: Array(images)
    def find_images_by_keyword_with_paginate(keyword, size, current)
      if keyword.blank?
        find(:all, :page => {:size => size, :current => current}, :order => "abm_images.updated_at desc")
      else
        find(:all, :page => {:size => size, :current => current},
             :conditions => ['abm_images.title like ? or abm_images.body like ?', "%#{keyword}%", "%#{keyword}%"], 
             :order => "abm_images.updated_at desc")
      end
    end

  end
  
private

  def validate_on_create
    
    unless AppResources[:abm][:user_size_max_image_size].nil?
      sum_file_size = AbmAlbum.sum_image_size_by_base_user_id(self.abm_album.base_user_id)
      sum_file_size = sum_file_size + self.image_size
    
      if sum_file_size > AppResources[:abm][:user_size_max_image_size].to_byte_i
        errors.add_to_base "利用可能容量制限以上の画像をアップロードしようとしています。"
        return
      end
    end
    
    unless AppResources[:abm][:system_size_max_image_size].nil?
      sum_file_size = AbmImage.sum(:image_size)
      sum_file_size = sum_file_size + self.image_size
      if sum_file_size > AppResources[:abm][:system_size_max_image_size].to_byte_i
        errors.add_to_base "システムが利用可能な容量制限以上の画像をアップロードしようとしています。"
      end
    end
  end

end
