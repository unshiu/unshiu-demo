
module AbmImageTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::UnitTest
        fixtures :abm_albums
        fixtures :abm_images
        fixtures :abm_image_comments
        fixtures :base_users
      end
    end
  end
  
  def test_relation
    abm_image = AbmImage.find(1)
    assert_not_nil abm_image.abm_album
    assert_not_nil abm_image.abm_image_comments
  end
  
  define_method('test: 同じアルバムでリスト的に次にある画像を取得する') do
    image = AbmImage.find(1)
    next_image = image.next
    assert_equal(next_image.abm_album_id, image.abm_album_id) # 同じアルバムである
    assert(next_image.id > image.id ) # id は増加している
    
    next_next_image = next_image.next
    assert_equal(next_next_image.abm_album_id, image.abm_album_id) 
    assert(next_next_image.id > next_image.id) 
    
    next_next_next_image = next_next_image.next
    assert_equal(next_next_next_image.abm_album_id, image.abm_album_id) 
    assert(next_next_next_image.id > next_next_image.id)
  end
  
  define_method('test: 同じアルバムでリスト的に次にある画像を指定数回数分取得する') do
    image = AbmImage.find(1)
    images = image.nexts(3)
    assert_equal(images.size, 3) 

    image = AbmImage.find(7)
    images = image.nexts(3)
    assert_equal(images.size, 0) # 次に画像がない
  end
  
  define_method('test: 同じアルバムでリスト的に前にある画像を取得する') do
    image = AbmImage.find(5)
    previous_image = image.previous
    
    assert_not_nil(previous_image)
    assert_equal(previous_image.abm_album_id, image.abm_album_id)
    assert(previous_image.id < image.id)
    
    previous_previous_image = previous_image.previous
    assert_equal(previous_previous_image.abm_album_id, image.abm_album_id)
    assert(previous_previous_image.id < previous_image.id)
  end
  
  define_method('test: 同じアルバムでリスト的に前にある画像を指定数回数分取得する') do
    image = AbmImage.find(1)
    images = image.previouses(3)
    assert_equal(images.size, 0) # 前に画像がない

    image = AbmImage.find(7)
    images = image.previouses(3)
    assert_equal(images.size, 3)
  end
  
  def test_mine?
    image = AbmImage.find(1)
    assert image.mine?(1)
    assert !image.mine?(5)
    assert !image.mine?(nil)
  end

  define_method('test: swfuploadでアップロードしたファイルを保存する') do 
    before_count = AbmImage.count(:conditions => ['abm_album_id = ?', 1])
    
    image_data = uploaded_file(file_path("file_column/abm_image/image/7/logo.gif"), "not/known", "local_filename.jpg")
    abm_image = AbmImage.new({:abm_album_id => 1, :swfupload_file => image_data})
    abm_image.save!
    
    after_count = AbmImage.count(:conditions => ['abm_album_id = ?', 1])
    assert_equal(before_count + 1, after_count)
  end
  
  define_method('test: 通常のでアップロードフォームでしたファイルを保存する') do 
    before_count = AbmImage.count(:conditions => ['abm_album_id = ?', 1])
    
    image_data = uploaded_file(file_path("file_column/abm_image/image/7/logo.gif"), "not/known", "local_filename.jpg")
    abm_image = AbmImage.new({:abm_album_id => 1, :upload_file => image_data})
    abm_image.save!
    
    after_count = AbmImage.count(:conditions => ['abm_album_id = ?', 1])
    assert_equal(before_count + 1, after_count)
  end
  
  define_method('test: public_all は全体へ公開されているのアルバムの写真一覧を取得する') do
    images = AbmImage.public_all
    
    assert_not_equal(images.size, 0)
    images.each do |image|
      assert_equal(image.abm_album.public_level, 1)
    end
  end
  
  define_method('test: find_images_by_keyword_with_paginate は指定キーワードをタイトルかアルバムに含む写真一覧を取得する') do
    images = AbmImage.find_images_by_keyword_with_paginate('花の写真', 10, 0)
    
    assert_not_equal(images.size, 0)
    images.each do |image|
      assert_equal(image.title, '花の写真')
    end
  end
  
  define_method('test: find_images_by_keyword_with_paginate は指定キーワードを長さ0の文字列で渡された場合写真一覧を取得する') do
    images = AbmImage.find_images_by_keyword_with_paginate('', 10, 0)
    
    assert_equal(images.size, AbmImage.count)
  end
  
  define_method('test: 全体へ公開されているのアルバムから特定のキーワードを持つ写真一覧を取得する') do
    images = AbmImage.public_all.find_images_by_keyword_with_paginate('花の写真', 10, 0)
    
    assert_not_equal(images.size, 0)
    images.each do |image|
      assert_equal(image.abm_album.public_level, 1)
    end
  end
end
