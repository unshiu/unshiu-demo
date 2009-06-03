module PrfHelperModule
  
  def prf_options(prf_question, new_answers)
    if new_answers
      current_choice_id = new_answers[prf_question.id].prf_choice_id
    else
      answer = current_base_user.prf_profile.answer(prf_question)
      current_choice_id = answer ? answer.prf_choice_id : nil
    end
    options_from_collection_for_select(prf_question.prf_choices, 'id', 'body', current_choice_id)
  end
  
#  def prf_option(choice)
#    selected = ''
#    current_choice = current_base_user.prf_profile.answer(choice.prf_question)
#    if current_choice && current_choice.prf_choice_id == choice.id
#      selected = " selected='selected'"
#    end
#    <<-END
#      <option value="#{choice.id}"#{selected}>#{h choice.body}</option>
#    END
#  end
  
  def prf_radio(choice, new_answers)
    checked = selected?(choice, new_answers) ? ' checked' : ''
    ret = "<input type='radio' name='q[#{choice.prf_question.id}]' value='#{choice.id}'#{checked}/>#{h choice.body}"
    if choice.has_free_area?
      body = current_base_user.prf_profile.answer(choice.prf_question).try(:body)
      if choice.free_area_type_text?
        ret += "<input type='text' name='c[#{choice.prf_question.id}][#{choice.id}]' value='#{body}'/>"
      elsif choice.free_area_type_textarea?
        ret += "<textarea name='c[#{choice.prf_question.id}][#{choice.id}]'>#{body}</textarea>"
      end
    end
    return ret
  end
  
  def prf_checkbox(choice, new_answers)
    answers = (new_answers)? new_answers[choice.prf_question_id] : current_base_user.prf_profile.answers(choice.prf_question)
    answer = nil
    selected = ''
    if answers
      answers.each do |a|
        if a.prf_choice_id == choice.id
          answer = a
          selected = " checked='checked'"
          break
        end
      end
    end
    ret = "<input type='checkbox' name='q[#{choice.prf_question.id}][#{choice.id}]' value='#{choice.id}'#{selected}/>#{choice.body}"
    if choice.has_free_area?
      body = answer ? answer.body : ''
      if choice.free_area_type_text?
        ret += "<input type='text' name='c[#{choice.prf_question.id}][#{choice.id}]' value='#{body}'/>"
      elsif choice.free_area_type_textarea?
        ret += "<textarea name='c[#{choice.prf_question.id}][#{choice.id}]'>#{body}</textarea>"
      end
    end
    return ret
  end

  def prf_text(question, new_answers)
    answer = (new_answers)? new_answers[question.id] : current_base_user.prf_profile.answer(question)
    body = answer ? answer.body : ''
    <<-END
      <input type='text' name='q[#{question.id}]' value='#{body}'/>
    END
  end

  def prf_textarea(question, new_answers)
    answer = (new_answers)? new_answers[question.id] : current_base_user.prf_profile.answer(question)
    body = answer ? answer.body : ''
    <<-END
      <textarea name='q[#{question.id}]'>#{body}</textarea>
    END
  end

  def prf_accessible?(prf_profile, base_user = current_base_user)
    UserRelationSystem.accessible?(base_user, prf_profile.base_user_id, prf_profile.public_level)
  end
  
  def answer_label(prf_answer)
    if prf_answer
      choice = prf_answer.prf_choice
      if choice
        if prf_answer.body.blank?
          return choice.body
        else
          return "#{choice.body}(#{prf_answer.body})"
        end
      end
    end
    return ''
  end

  private
  def selected?(choice, new_answers)
    if new_answers
      ans = new_answers[choice.prf_question_id]
    else
      ans = current_base_user.prf_profile.answer(choice.prf_question)
    end
    return false if ans == nil
    return ans.prf_choice_id == choice.id
  end
end
