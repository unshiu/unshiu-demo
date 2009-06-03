require File.dirname(__FILE__) + '/../../test_helper'

class StringExpanseTest < Test::Unit::TestCase
  
  define_method('test: 前後の空白文字を削除する') do 
    assert_equal "　あいうえお　".strip_with_full_size_space!, "あいうえお"
  end
  
  define_method('test: 1Kをbyteに単位変換した数字にする') do 
    assert_equal "1K".to_byte_i, 1024
    assert_equal "10K".to_byte_i, 10240
  end
  
  define_method('test: 1Mをbyteに単位変換した数字にする') do 
    assert_equal "1M".to_byte_i, 1048576
    assert_equal "32M".to_byte_i, 33554432
  end
  
  define_method('test: 1Gをbyteに単位変換した数字にする') do 
    assert_equal "1G".to_byte_i, 1073741824
    assert_equal "32G".to_byte_i, 34359738368
  end
  
  define_method('test: 1Tをbyteに単位変換した数字にする') do 
    assert_equal "1T".to_byte_i, 1099511627776
    assert_equal "76T".to_byte_i, 83562883710976
  end
end