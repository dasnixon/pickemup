module PreferencesHelper
  extend ActiveSupport::Concern

  def get_preference_defaults
    self.class::HASHABLE_PARAMS.each { |attr| self.send("#{attr}=", get_attr_values(attr)) }
  end

  def get_attr_values(attr)
    checked_attributes = self.class.create_param_hash(self.send(attr), true)
    unchecked_attributes = self.class.create_param_hash(attribute_default_values(attr) - self.send(attr), false)
    checked_attributes + unchecked_attributes
  end

  module ClassMethods
    def create_param_hash(attributes, check_value=false)
      attributes.collect { |attr| { name: attr, checked: check_value } }
    end

    def cleanup_invalid_data(parameters)
      self::HASHABLE_PARAMS.each do |attr|
        next unless parameters.has_key?(attr)
        unless parameters[attr].is_a?(Array)
          parameters.delete(attr)
          next
        end
        parameters[attr] = reject_attrs(parameters[attr])
        parameters[attr].collect! { |attrs| attrs['name'] }
      end
      parameters
    end

    def reject_attrs(param)
      param.reject do |attributes|
        !(attributes.has_key?('checked') && attributes.has_key?('name')) ||
          attributes.keys.length > 2 ||
          ![TrueClass, FalseClass].include?(attributes['checked'].class) ||
          !attributes['checked']
      end
    end
  end
end
