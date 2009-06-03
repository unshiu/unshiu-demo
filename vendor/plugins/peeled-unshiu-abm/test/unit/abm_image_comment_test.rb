
module AbmImageCommentTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :abm_images
        fixtures :abm_image_comments
      end
    end
  end
  
  def test_relation
    abm_image_comment = AbmImageComment.find(1)
    assert_not_nil abm_image_comment.abm_image
    assert_not_nil abm_image_comment.base_user
  end
  
  define_method('test: ある画像の最新コメントを指定数分取得する') do 
    abm_image = AbmImage.find(1)
    
    comment = abm_image.abm_image_comments.recent(2)
    assert_not_nil(comment)
    assert_equal(comment.length, 2)
    
    comment = abm_image.abm_image_comments.recent(1)
    assert_not_nil(comment)
    assert_equal(comment.length, 1)
  end
   
end
