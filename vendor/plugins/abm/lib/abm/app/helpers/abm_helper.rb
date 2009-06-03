module AbmHelperModule
  
  # imageの次の画像を表示するヘルパー。
  # 次の画像が存在しない場合は空文字を返す。
  def link_to_next(name, image) 
    ret = ""
    next_image = image.next
    if next_image
      ret = link_basic_to name, :action => :show, :id => next_image.id
    end

    ret
  end

  # imageの前の画像を表示するヘルパー
  # 前の画像が存在しない場合は空文字を返す。
  def link_to_previous(name, image)
    ret = ""
    previous_image = image.previous
    if previous_image
      ret = link_basic_to name, :action => :show, :id => previous_image.id
    end
    
    ret
  end
  
  # アルバム表紙画像を表示する。あれば表示しなければデフォルトを利用する
  def safe_abm_album_cover_image_view(abm_image, size, html_option={})
    if abm_image.nil? || abm_image.image.blank?
			image_tag_for_default 'icon/default_album_image.png', html_option
		else
			image_tag url_for_image_column(abm_image, :image, size), html_option
		end
  end
  
end