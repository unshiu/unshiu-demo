#
# ユーザメニュー情報のマスタ
# 
class BaseMenuMaster
  attr_accessor :id, :name, :icon, :url, :num, :default_show
  
  def initialize(attribute = {})
    self.id = attribute["id"]
    self.name = attribute["name"]
    self.icon = attribute["icon"]
    self.url = attribute["url"]
    self.default_show = attribute["default_show"]
    self.num = attribute["num"]
  end
  
  def self.find(base_master_id)
    self.load_yaml_file
    @@master_menus.each { |menu| return menu if menu.id == base_master_id }
  end
  
  # メニュー一覧をすべて返す。
  # 指定順でソートしているが、標準で表示するメニュー、しないメニューの順になっている
  def self.all_menus
    all_default_show_menus + all_default_unshow_menus
  end
  
  # 標準で表示するメニュー一覧を指定順でソートし返す
  # return:: メニュー一覧　array
  def self.all_default_show_menus
    self.load_yaml_file
    show_menu = []
    @@master_menus.each { |menu| show_menu << menu if menu.default_show }
    show_menu = show_menu.sort { |a, b| a.num <=> b.num}
    show_menu
  end
  
  # 標準で表示しないメニュー一覧を指定順でソートし返す
  # return:: メニュー一覧　array
  def self.all_default_unshow_menus
    self.load_yaml_file
    show_menu = []
    @@master_menus.each { |menu| show_menu << menu unless menu.default_show }
    show_menu = show_menu.sort { |a, b| a.num <=> b.num}
    show_menu
  end
  
private

  def self.load_yaml_file
    @@yaml ||= YAML.load_file(RAILS_ROOT + "/" + AppResources[:base][:menu_master_file])
    @@master_menus ||= []
    if @@master_menus.empty?
      @@yaml.each do |menu|
        master = BaseMenuMaster.new(menu[1])
        @@master_menus << master
      end
    end
  end
end