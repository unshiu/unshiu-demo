# FIXME かなり無駄なことをしている。要リファクタリング
module Forms
  module BaseTransitFormModule
    attr_accessor :type
    attr_accessor :date
    attr_accessor :csv
    attr_accessor :start_year, :start_month, :start_day, :end_year, :end_month, :end_day

    def initialize(type, date, csv)
      @type = type
      @date = date
      @csv = csv
    end
  
    def validate
      if !day? && !month?
        self.errors.add('type', '指定タイプが不正です。')
      end
    
      @start_year = date['start(1i)'].to_i
      @start_month = date['start(2i)'].to_i
      @end_year = date['end(1i)'].to_i
      @end_month = date['end(2i)'].to_i
      @start_day = date['start(3i)'].to_i
      @end_day = date['end(3i)'].to_i
    
      start_date_value = start_date
      end_date_value = end_date
    
      if !start_date_value.nil? && !end_date_value.nil?
        if start_date_value > end_date_value
          self.errors.add('end_at', I18n.t('activerecord.errors.messages.after_date', 
                                           {:date => I18n.t('activerecord.attributes.forms/base_transit_form.start_at')}))
        end
      end
    
    end
  
    def start_date
      begin
        if day?
          Date.new(@start_year, @start_month, @start_day)
        elsif month?
          Date.new(@start_year, @start_month, 1)
        end
      rescue ArgumentError
        self.errors.add('date','存在しない日付です。')
        return nil
      end
    end
  
    def end_date
      begin
        if day?
          Date.new(@end_year, @end_month, @end_day)
        elsif month?
          Date.new(@end_year, @end_month, 1)
        end
      rescue ArgumentError
        self.errors.add('date','存在しない日付です。')
        return nil
      end
    end
  
    def day?
      @type == 'day' ? true : false
    end
  
    def month?
      @type == 'month' ? true : false
    end
  
    def csv?
      @csv
    end
  end
end