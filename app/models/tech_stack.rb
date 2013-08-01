class TechStack < ActiveRecord::Base
  attr_accessible :name
  belongs_to :company

  HASHABLE_PARAMS = ['back_end_languages', 'front_end_languages', 'dev_ops_tools', 'frameworks']

  def unhash_all_params(tech_stack_params)
    HASHABLE_PARAMS.each do |param|
      all_params = tech_stack_params[param]
      if all_params
        new_params = all_params.select { |attr| attr["checked"] == true }.map { |attr| attr["name"] }
        eval("self.#{param} = #{new_params}")
        tech_stack_params.delete(param)
      end
    end
    tech_stack_params
  end

  def create_param_hash(attributes, check_value = false)
    attributes.map { |attr| {name: attr, checked: check_value} }
  end

  def populate_all_params
    HASHABLE_PARAMS.each do |param|
      stored_params = self.try(param)
      checked = stored_params ? stored_params : []
      unchecked_defaults = ("PreferenceConstants::#{param.upcase}".constantize - checked)
      params_to_render = create_param_hash(checked, true) + create_param_hash(unchecked_defaults)
      eval("self.#{param} = #{params_to_render}")
    end
  end
end
