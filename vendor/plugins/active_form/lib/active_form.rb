# Note ".valid?" method  must occur on object for validates_associated
class ActiveForm
  
  class << self

    def self_and_descendants_from_active_record
      [self]
    end

    def human_name(options = {})
      defaults = self_and_descendants_from_active_record.map do |klass|
        :"#{klass.name.underscore}"
      end 
      defaults << self.name.humanize
      I18n.translate(defaults.shift, {:scope => [:activerecord, :models], :count => 1, :default => defaults}.merge(options))
    end

    def human_attribute_name(attribute_key_name, options = {})
      defaults = self_and_descendants_from_active_record.map do |klass|
        :"#{klass.name.underscore}.#{attribute_key_name}"
      end
      defaults << options[:default] if options[:default]
      defaults.flatten!
      defaults << attribute_key_name.humanize
      options[:count] ||= 1
      I18n.translate(defaults.shift, options.merge(:default => defaults, :scope => [:activerecord, :attributes]))
    end

  end
  
  def initialize(attributes = nil)
    self.attributes = attributes
    yield self if block_given?
  end

  def id
    self.object_id
  end

  def attributes=(attributes, guard_protected_attributes = true)
    attributes = filter_attributes(attributes) if !attributes.blank? && guard_protected_attributes
    attributes.each do |key,value|
      send(key.to_s + '=', value)
    end if attributes
  end

  def attributes
    attributes = instance_variables
    attributes.delete("@errors")
    Hash[*attributes.collect { |attribute| [attribute[1..-1], instance_variable_get(attribute)] }.flatten]
  end

  def [](key)
    instance_variable_get("@#{key}")
  end

  def []=(key, value)
    instance_variable_set("@#{key}", value)
  end

  def new_record?
    true
  end

  def method_missing( method_id, *args )
    if md = /_before_type_cast$/.match(method_id.to_s)
      attr_name = md.pre_match
      return self[attr_name] if self.respond_to?(attr_name)
    end
    super
  end

  def to_xml(options = {})
    options[:root] ||= self.class.to_s.underscore
    attributes.to_xml(options)
  end

  alias_method :respond_to_without_attributes?, :respond_to?

  def new_record?
    true
  end
  
  def self.attr_accessible (*attrs)
    # The Rails version
    # write_inheritable_attribute("attr_accessible", Set.new(attrs.map(&:to_s)) + (accessible_attributes || []))
    
    write_inheritable_attribute(:attr_accessible, attrs)
  end

  protected 
  def raise_not_implemented_error(*params)
    ValidatingModel.raise_not_implemented_error(*params)
  end

  def logger
    RAILS_DEFAULT_LOGGER
  end

  # these methods must be defined before Validations include
  alias save raise_not_implemented_error
  alias update_attribute raise_not_implemented_error
  alias save! raise_not_implemented_error
  
  # The following must be defined prior to Callbacks include
  alias create_or_update raise_not_implemented_error
  alias create raise_not_implemented_error
  alias update raise_not_implemented_error
  alias destroy raise_not_implemented_error

  def self.instantiate(record)
    object = allocate
    object.attributes = record
    object
  end

  public
  include ActiveRecord::Validations
  include ActiveRecord::Callbacks

  protected 

  # the following methods must be defined after include so that they override
  # methods previously included
  class << self
    def raise_not_implemented_error(*params)
      raise NotImplementedError
    end

    alias validates_uniqueness_of raise_not_implemented_error
    alias create! raise_not_implemented_error
    alias validate_on_create raise_not_implemented_error
    alias validate_on_update raise_not_implemented_error
    alias save_with_validation raise_not_implemented_error    
  end
  
  def filter_attributes(attributes)
    attr_accessible = self.class.read_inheritable_attribute(:attr_accessible)
    return attributes if attr_accessible.blank?
    
    new_attrs = {}
    attr_accessible.each do |k|
      new_attrs[k] = attributes[k] if attributes.has_key? k
    end
    attributes = new_attrs
  end
  
end
