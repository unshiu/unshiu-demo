require File.dirname(__FILE__) + '/../spec_helper'

describe "H11T モバイルブラウザからのアクセス", :behaviour_type=>:controller do
  before do
    request.env["HTTP_USER_AGENT"] = request.user_agent = "emobile/1.0.0 (H11T; like Gecko; Wireless) NetFront/3.4"
    request.env['HTTP_X_EM_UID'] = "u00000000000000000"
    request.env['REMOTE_ADDR'] = "117.55.1.232"
  end
  controller_name :mobile_spec
  it "request.mobile は Emobile のインスタンスであること" do
    request.mobile.should be_an_instance_of(Jpmobile::Mobile::Emobile)
  end
  it "request.mobile? は true であること" do
    request.mobile?.should be_true
  end
  it "のsubscribe番号を取得できること" do
    request.mobile.ident_subscriber.should == "u00000000000000000"
  end
  it "のIPアドレス空間を正しく検証できること" do
    request.mobile.valid_ip?.should be_true
  end
  it "のデバイスIDを取得できること" do
    request.mobile.device_id.should == "H11T"
  end
  it "の機種名を取得できること" do
    request.mobile.device_name.should == "H11T"
  end
  it "のcss? は true であること" do
    request.mobile.css?.should be_true
  end
  it "のgif? は true であること" do
    request.mobile.gif?.should be_true
  end
  it "のjpg? は true であること" do
    request.mobile.jpg?.should be_true
  end
  it "のpng? は true であること" do
    request.mobile.png?.should be_true
  end
  it "のflash? は true であること" do
    request.mobile.flash?.should be_true
  end
  it "のflashバージョン は 2.0 であること" do
    request.mobile.flash_version.should == "2.0"
  end
  it "のssl? は true であること" do
    request.mobile.ssl?.should be_true
  end
end

describe "S11HT からのアクセス", :behaviour_type=>:controller do
  before do
    request.env["HTTP_USER_AGENT"] = request.user_agent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 7.7) S11HT"
  end
  controller_name :mobile_spec
  it "request.mobile は Emobile のインスタンスであること" do
    request.mobile.should be_an_instance_of(Jpmobile::Mobile::Emobile)
  end
  it "request.mobile? は true であること" do
    request.mobile?.should be_true
  end
  it "のデバイスIDを取得できること" do
    request.mobile.device_id.should == "S11HT"
  end
  it "はオープンブラウザなので機種名取得は未対応" do
    request.mobile.device_name.should be_nil
  end
  it "はオープンブラウザなのでcss?は未対応" do
    request.mobile.css?.should be_nil
  end
  it "はオープンブラウザなのでgif?は未対応" do
    request.mobile.gif?.should be_nil
  end
  it "はオープンブラウザなのでjpg?は未対応" do
    request.mobile.jpg?.should be_nil
  end
  it "はオープンブラウザなのでpng?は未対応" do
    request.mobile.png?.should be_nil
  end
  it "はオープンブラウザなのでflash?は未対応" do
    request.mobile.flash?.should be_nil
  end
  it "はオープンブラウザなのでflash_versionは未対応" do
    request.mobile.flash_version.should be_nil
  end
  it "はオープンブラウザなのでssl?は未対応" do
    request.mobile.ssl?.should be_nil
  end
end
