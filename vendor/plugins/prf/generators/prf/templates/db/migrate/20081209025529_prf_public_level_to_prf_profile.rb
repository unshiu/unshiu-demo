class PrfPublicLevelToPrfProfile < ActiveRecord::Migration
  def self.up
    add_column :prf_profiles, :public_level,  :integer, :null => false
    remove_column :prf_answers, :public_level
    remove_column :prf_question_sets, :prf_profile_id
  end

  def self.down
    remove_column :prf_profiles, :public_level
    add_column :prf_answers, :public_level,  :integer
    add_column :prf_question_sets, :prf_profile_id,  :integer, :null => false
  end
end
