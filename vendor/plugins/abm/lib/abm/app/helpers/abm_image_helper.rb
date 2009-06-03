module AbmImageHelperModule
  # 画像コメント表示用のヘルパー
  # 自分が書き込んだコメント、もしくは自分の画像に付いたコメントなら"削除する"リンクを表示する。
  def view_comment(comment)
    time = date_or_time comment.created_at
    body = h comment.body
    posted_by = link_to comment.base_user.show_name,
                :controller => 'base_profile',
                :action => 'show',
                :id => comment.base_user_id
    if current_base_user
      if current_base_user.me?(comment.base_user_id) or comment.abm_image.mine?(current_base_user.id)
        delete_link = link_to "削除する",
                            :action => 'confirm_delete_comment',
                            :id => comment.id
      end
    end
    
    ret = "#{date_or_time(comment.created_at)} #{comment.body} #{posted_by}"
    ret += " #{delete_link}"
    ret
  end

end
