require 'fileutils'
#
# 全体で利用されるユーティリティ系
#
class Util
  RAND_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz"

  # ランダムな英数字を生成する
  # _param1_:: len 生成する英数字
  # return :: ランダムな英数字
  def self.random_string(len)
    rand_max = RAND_CHARS.size
    ret = ""
    len.times{ ret << RAND_CHARS[rand(rand_max)] }
    ret
  end
  
  # ランダムな英数字のキーが未作成なら生成し保存し２回目以降はそれを用いる
  # _param1_:: key名
  # return :: ランダムな英数字
  def self.secret_key(key)
    secret_path = File.join(RAILS_ROOT, "public/system/files/secret_key/")
    Dir::mkdir(secret_path) unless File.exist?(secret_path)
    secret_path = secret_path + "#{key}.txt"
    
    if File.exist?(secret_path)
      secret = open(secret_path) { |io| io.read }.gsub(/\s/, '')
    end
    if secret.nil? || secret.empty?
      value = Util.random_string(32)
      open(secret_path, "w") { |io| io.write(value) }
      return value
    else
      return secret
    end
  end
  
  # デバイスごとのリソースキー名を取得する
  def self.resources_keyname_from_device(key, mobile)
    suffix = (!mobile.nil? && mobile) ? "_mobile" : ""
    key + suffix
  end
end