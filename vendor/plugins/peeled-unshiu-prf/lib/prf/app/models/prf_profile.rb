# == Schema Information
#
# Table name: prf_profiles
#
#  id           :integer(4)      not null, primary key
#  base_user_id :integer(4)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#  prf_image_id :integer(4)
#  public_level :integer(4)      not null
#

module PrfProfileModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        acts_as_unshiu_user_relation
        
        belongs_to :base_user
        has_many :prf_answers, :dependent => :destroy
        has_one :prf_image, :dependent => :destroy
        acts_as_searchable :searchable_fields => []

        const_set('QUESTION_ATTR_PREFIX',              "q")
        const_set('QUESTION_ATTR_SUFFIX_ID',           "id")
        const_set('QUESTION_ATTR_SUFFIX_TEXT',         "text")
        const_set('PROFILE_ATTR_SUFFIX_PUBLIC_LEVEL', "pub")
        const_set('CHOICES_ATTR_DELIMITER',            "/")
        
        alias_method_chain :document_object, :include
      end
    end
  end
  
  # FIXME 未使用？とりあえずテストコードも保留
  def answer_hash(question)
    answers = PrfAnswer.find_all_by_prf_profile_id_and_prf_question_id(id, question_id)
    answers_hash = {}
    answers.each do |a|
      answers_hash.store(a.prf_choice_id, a)
    end
    return answers_hash
  end

  # このプロフィールの question の回答を1つ探す
  def answer(question)
    return PrfAnswer.find_by_prf_profile_id_and_prf_question_id(id, question.id)
  end
  
  # このプロフィールの question の回答をすべて探す
  def answers(question_id)
    return PrfAnswer.find_all_by_prf_profile_id_and_prf_question_id(id, question_id)
  end

  # answer の validation をして、profile の errors へ再構成する
  # _return_:: エラーがなければ true，あれば false
  def valid_with_answers?(prf_answers)
    for prf_answer in prf_answers
      unless prf_answer.valid?
        prf_answer.errors.each{ |attr, message|
          self.errors.add(prf_answer.prf_question.body, message)
        }
      end
    end
    
    self.errors.empty?
  end
  
  # prf_profileをsaveかupdateしたときに、プロフィール各項目をestraierに格納する
  def document_object_with_include
    doc = document_object_without_include
    
    # デフォルトのquestion_setを取得
    question_set = PrfQuestionSet.find_basic_profile
    # textは全文検索対象の文書
    text = ""
    # attrsはestraierのindexにATTRIBUTEとして保存するもの
    attrs = {}
    
    question_set.prf_question_set_partials.each do |qsp|
      question = qsp.prf_question
      if question.type_select? || question.type_radio?
        # questionがselectかradioだったら(要するに択一だったら)、
        #  q123idというキーで、choiceのidを
        #  q123textというキーで、choiceの本文を
        #  q123pubというキーで、answerのpublic_levelを
        # 格納する
        # public_level が all で、自由記述欄があるものは、自由記述欄の中を全文検索対象に入れる
        answer = self.answer(question)
        if answer
          attrs[PrfProfile.question_public_level_attr_name(question.id)] = self.public_level.to_s
          attrs[PrfProfile.question_id_attr_name(question.id)] = answer.prf_choice.id.to_s
          attrs[PrfProfile.question_text_attr_name(question.id)] = answer.prf_choice.body.to_s
          if !answer.body.blank? && self.public_level == UserRelationSystem::PUBLIC_LEVEL_ALL
            doc.add_text answer.body + "\n"
          end
        end
      elsif question.type_checkbox?
        # questionがchoiceだったら
        #  q123idというキーで、choiceのidを
        #  q123textというキーで、choiceの本文を
        #  q123pubというキーで、answerのpublic_levelを
        # 格納する
        # なお、delimiterで区切ってたくさん入れる
        # 例：
        #  q123id = /1/10/23/78/
        #  q123text = /肉/魚/蟷螂/加来さん/
        # public_level が all で、自由記述欄があるものは、自由記述欄の中を全文検索対象に入れる
        attrs[PrfProfile.question_id_attr_name(question.id)] = PrfProfile::CHOICES_ATTR_DELIMITER
        attrs[PrfProfile.question_text_attr_name(question.id)] = PrfProfile::CHOICES_ATTR_DELIMITER
        answers = self.answers(question)
        if answers.size > 0
          attrs[PrfProfile.question_public_level_attr_name(question.id)] = self.public_level.to_s
        end
        answers.each do |answer|
          attrs[PrfProfile.question_id_attr_name(question.id)] += answer.prf_choice.id.to_s + PrfProfile::CHOICES_ATTR_DELIMITER
          attrs[PrfProfile.question_text_attr_name(question.id)] += answer.prf_choice.body.to_s + PrfProfile::CHOICES_ATTR_DELIMITER
          if answer && !answer.body.nil? && self.public_level == UserRelationSystem::PUBLIC_LEVEL_ALL
            doc.add_text answer.body + "\n"
          end
        end
      elsif question.type_text? || question.type_textarea?
        # public_level が all で、自由記述のものは、全文検索対象に入れる
        answer = self.answer(question)
        if answer && self.public_level == UserRelationSystem::PUBLIC_LEVEL_ALL
          doc.add_text answer.body + "\n"
        end
      end
    end

    attrs.each_pair do |key, value|
      doc.add_attr(key, value.to_s)
    end
    # prf_profileから直接取れないようなものは、optional_attrsとしてとる
    optional_attrs.each_pair do |key, value|
      doc.add_attr(key, value.to_s)
    end
  
    doc
  end

  # estraierに登録するattributeを書く
  # 返し値は {key1 => value1, key2 => value2, ... }であるhashで、それがそのままestraier側に登録される。
  # なお、keyとvalueは全てstringである前提(全てto_sしてから処理されるので変なもの入れても一応動くけど)
  # return {}
  # TODO 案件にあわせた追加
  def optional_attrs
    return {'mail' => self.base_user.email}
  end
  
  module ClassMethods
    
    # デフォルトプロフィールを作成して返す
    # return:: デフォルトプロフィール
    def new_default_profile(params = {})
      params[:public_level] = UserRelationSystem::PUBLIC_LEVEL_ME
      new(params)
    end
    
    # 画像付きメールを受信し、プロフィール画像として設定する
    # _param1_:: mail 
    # _param2_:: base_mail_dispatch_info
    def receive(mail, base_mail_dispatch_info)
      unless mail.has_attachments?
        BaseMailerNotifier::deliver_failure_saving_prf_images(mail, '添付画像がありません。')
        return
      end
      
      if mail.attachments.size > 1 # 添付ファイルがあり過ぎる
        BaseMailerNotifier::deliver_failure_saving_prf_images(mail, '添付された画像が2つ以上あります。')
        return
      end
      
      unless BaseMailerNotifier.image?(mail.attachments.first) # 画像じゃない
        BaseMailerNotifier::deliver_failure_saving_prf_images(mail, '添付ファイルが画像ではありません。')
        return
      end        
      
      PrfProfile.transaction { receive_core(mail, base_mail_dispatch_info) }
      prf_profile = PrfProfile.find(base_mail_dispatch_info.model_id)
      BaseMailerNotifier::deliver_success_saving_prf_images(mail, prf_profile.base_user_id)
    
    rescue => ex
      logger.info ex.to_s
      BaseMailerNotifier::deliver_failure_saving_prf_images(mail)
    end
  
    # 全ての要素を検索(管理者向け、公開レベルを気にしない)
    # _param1_:: searches   プロフィールの配列。question_id,choice_idのhash配列(typeがselect,radio,checkbox以外は無視されます)
    # _param2_:: keyword    全文検索の単語
    # _param3_:: attributes estraierに投げるattributes
    # _param4_:: options    option
    # _return_:: prf_profileの配列
    def find_by_all_profile(searches = nil, keyword = nil, attributes = [], options = {})
      if searches
        searches.each_pair do |q_id, c_id|
          question = PrfQuestion.find(q_id)
          if question.type_select? || question.type_radio?
            attributes.push "#{PrfProfile.question_id_attr_name(q_id)} NUMEQ #{c_id}"
          elsif question.type_checkbox?
            attributes.push "#{PrfProfile.question_id_attr_name(q_id)} STRINC #{PrfProfile::CHOICES_ATTR_DELIMITER}#{c_id}#{PrfProfile::CHOICES_ATTR_DELIMITER}"
          end
        end
      end
      options.merge!({:attributes => attributes, :order => 'updated_at NUMD', :find => {:order => 'updated_at desc'}})
      fulltext_search(keyword, options)
    end

    # 全ての要素を検索(ユーザー向け、全体に公開のもののみ)
    # _param1_:: searches   プロフィールの配列。question_id,choice_idのhash配列(typeがselect,radio,checkbox以外は無視されます)
    # _param2_:: keyword    全文検索の単語
    # _param3_:: attributes estraierに投げるattributes
    # _param4_:: options    option
    # _return_:: prf_profileの配列
    def find_by_public_profile(searches = nil, keyword = nil, attributes = [], options = {})
      if searches
        searches.each_pair do |q_id, c_id|
          attributes.push "#{PrfProfile.question_public_level_attr_name(q_id)} NUMEQ #{UserRelationSystem::PUBLIC_LEVEL_ALL}"
        end
      end

      find_by_all_profile(searches, keyword, attributes, options)
    end

    # estraier 向け attribute_name を作るメソッド
    def question_id_attr_name(id)
      PrfProfile::QUESTION_ATTR_PREFIX + id.to_s + PrfProfile::QUESTION_ATTR_SUFFIX_ID
    end
    
    def question_text_attr_name(id)
      PrfProfile::QUESTION_ATTR_PREFIX + id.to_s + PrfProfile::QUESTION_ATTR_SUFFIX_TEXT
    end
    
    def question_public_level_attr_name(id)
      PrfProfile::QUESTION_ATTR_PREFIX + id.to_s + PrfProfile::PROFILE_ATTR_SUFFIX_PUBLIC_LEVEL
    end
  
  private
  
    # プロフィール画像を受信したときのメインの処理
    # _param1_:: mail
    # _param2_:: base_mail_dispatch_info
    def receive_core(mail, base_mail_dispatch_info)
      profile = PrfProfile.find(base_mail_dispatch_info.model_id)
      if profile.prf_image
        profile.prf_image.image = mail.attachments.first
        profile.prf_image.save!
      else
        image = PrfImage.new
        image.prf_profile_id = base_mail_dispatch_info.model_id
        image.save!
        
        profile.prf_image_id = image.id
        profile.save!
      end
    end
    
  end

end
