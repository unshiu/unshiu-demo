require 'acts_as_searchable'

module ActiveRecord #:nodoc:
  module Acts
    module Searchable
      def self.included(base)
        base.extend ClassMethods        
        base.class_eval do
          class << self
            VALID_FULLTEXT_OPTIONS << :page
          end
        end
      end
      
      module ActMethods
        # バグ修正
        def document_object #:nodoc:
          doc = EstraierPure::Document::new
          doc.add_attr('db_id', "#{id}")
          doc.add_attr('type', "#{self.class.to_s}")
          doc.add_attr('@uri', "/#{self.class.to_s}/#{id}")
          
          unless attributes_to_store.blank?
            attributes_to_store.each do |attribute, method|
              value = send(method || attribute)
              value = value.xmlschema if value.is_a?(Time)
              # doc.add_attr(attribute_name(attribute), send(method || attribute).to_s)
              # 明らかなバグ Time 型に対応するフリをして対応していなかったので修正 
              doc.add_attr(attribute_name(attribute), value.to_s)
            end
          end

          searchable_fields.each do |f|
            doc.add_text send(f)
          end

          doc          
        end
        
        # rails2.1 の　Dirty tracking　と衝突するため削除
        # http://ryandaigle.com/articles/2008/3/31/what-s-new-in-edge-rails-dirty-objects
        remove_method :changed?
        remove_method :clear_changed_attributes
        remove_method :write_changed_attribute
      end      

      module ClassMethods
        
        # rails2.1 の　Dirty tracking　と衝突するため上書き
        # http://ryandaigle.com/articles/2008/3/31/what-s-new-in-edge-rails-dirty-objects
        def acts_as_searchable(options = {})
          return if self.included_modules.include?(ActiveRecord::Acts::Searchable::ActMethods)

          send :include, ActiveRecord::Acts::Searchable::ActMethods

          cattr_accessor :searchable_fields, :attributes_to_store, :if_changed, :estraier_connection, :estraier_node,
            :estraier_host, :estraier_port, :estraier_user, :estraier_password

          self.estraier_node        = estraier_config['node'] || RAILS_ENV
          self.estraier_host        = estraier_config['host'] || 'localhost'
          self.estraier_port        = estraier_config['port'] || 1978
          self.estraier_user        = estraier_config['user'] || 'admin'
          self.estraier_password    = estraier_config['password'] || 'admin'
          self.searchable_fields    = options[:searchable_fields] || [ :body ]
          self.attributes_to_store  = options[:attributes] || {}
          self.if_changed           = options[:if_changed] || []

          class_eval do
            after_update  :update_index
            after_create  :add_to_index
            after_destroy :remove_from_index

            connect_estraier
          end
        end
        
        # TODO 全文検索エンジンを使わずに検索するオフモードも作る
        # どの程度一般化できるか検討
        def fulltext_search_with_pagination(query = "", options = {})
          if options[:page]
            page_options = options.delete(:page)
            current = page_options[:current] && page_options[:current].to_i > 0 ? page_options[:current] : 1
            first = page_options[:first] || 1
            auto = page_options[:auto] || false
            options_dup = options.dup
            options_dup[:raw_matches] = true
            total_size = fulltext_search_without_pagination(query, options_dup).size
            # FIXME ↑これって結局全件で検索している気がする
            page_size = page_options[:size] || total_size
            return PagingEnumerator.new(page_size, total_size, auto, current, first) do |page|
              options[:offset] = (page - 1) * page_size
              limit = options[:limit] || 100
              if options[:offset] + page_size > limit
                options[:limit] = limit - options[:offset]
              else
                options[:limit] = page_size
              end
              fulltext_search_without_pagination(query, options)
            end
          end
    
          fulltext_search_without_pagination(query, options)
        end
        alias_method_chain :fulltext_search, :pagination
      end
    end
  end
end
