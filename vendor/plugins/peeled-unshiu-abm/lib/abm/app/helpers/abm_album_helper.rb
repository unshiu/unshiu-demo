module AbmAlbumHelperModule
  
  ALBUM_CYCLE_COUNT = 4
  def album_cycle_header(index)
    "<div class='album_list_row'>" if index % ALBUM_CYCLE_COUNT == 0
  end
  
  def album_cycle_footer(index, albums)
    "</div><hr/>" if index % ALBUM_CYCLE_COUNT == (ALBUM_CYCLE_COUNT - 1) || index+1 == albums.to_a.size
  end
  
end
