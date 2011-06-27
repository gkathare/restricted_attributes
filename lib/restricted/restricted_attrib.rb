module RestrictedAttrib
 
  ## Class Methods
  module ClassMethods
    def self.extended(base)
       base.before_validation :check_for_restricted_values
    end
  end

  ## Instance Methods
  module InstanceMethods
    # check the changed attributes of a class are restricted or not.
    def check_for_restricted_values
      
      if self.declarative # Using declarative_authorization roles system
        roles = RestrictedRightsManager.get_roles(Authorization.current_user,self)
        restrict_read_only = RestrictedRightsManager.get_readonly_fields(roles,self)
        restrict_create_only = RestrictedRightsManager.get_createonly_fields(roles,self)
        restrict_update_only = RestrictedRightsManager.get_updateonly_fields(roles,self)
        restrict_hidden_only = RestrictedRightsManager.get_hiddenonly_fields(roles,self)
      else # simple one
        restrict_read_only = self.read_only
        restrict_create_only = self.create_only
        restrict_update_only = self.update_only
        restrict_hidden_only = self.hidden_only
      end

      # check for read only attributes
      unless restrict_read_only.blank?
        restrict_read_only.each do |ro|
          if self.changed.include?(ro)
            self.errors.add(ro.humanize, self.read_only_message)
          end
        end
      end

      # check for create only attributes
      if !restrict_create_only.blank? && !self.new_record?
        restrict_create_only.each do |co|
          if self.changed.include?(co)
            self.errors.add(co.humanize, self.create_only_message)
          end
        end
      end

      # check for update only attributes
      if !restrict_update_only.blank? && self.new_record?
        restrict_update_only.each do |uo|
          if self.changed.include?(uo)
            self.errors.add(uo.humanize, self.update_only_message)
          end
        end
      end

      # check for hidden only attributes
      if !restrict_hidden_only.blank?
        restrict_hidden_only.each do |ho|
          if self.changed.include?(ho)
            self.errors.add(ho.humanize, self.hidden_only_message)
          end
        end
      end
      
      # will return validation result
      return false unless self.errors.blank?
    end

    def is_restricted?(action, field, user = nil)
      action = action.to_s
      field = field.to_s
      klass = self.class
      klass_object = self

      unless klass_object.methods.include?("read_only")
         raise NoMethodError, "undefined method `is_restricted?` for #{klass} model. You need to add `has_restricted_method` method in #{klass} model."
      end

      if action.nil? || !['create', 'update', 'read'].include?(action)
        raise ArgumentError, "Invalid action - (#{action}), Pass valid action - :read or :create or :update or 'read' or 'create' or 'update'"
      end

      klass_attributes = klass_object.attributes.keys
      if field.nil? || !klass_attributes.include?(field)
        raise ActiveRecord::UnknownAttributeError, "#{klass}: unknown attribute(field): #{field}"
      end

      if klass_object.declarative
        begin
          user.roles if user
        rescue
          raise ArgumentError, "invalid user (#{user}) paramater sent with `is_restricted?` method."
        end
        present_user = Authorization.current_user
        Authorization.current_user = user if user && user.roles

        roles = RestrictedRightsManager.get_roles(Authorization.current_user,klass_object)
        restrict_read_only = RestrictedRightsManager.get_readonly_fields(roles,klass_object)
        restrict_create_only = RestrictedRightsManager.get_createonly_fields(roles,klass_object)
        restrict_update_only = RestrictedRightsManager.get_updateonly_fields(roles,klass_object)
        restrict_hidden_only = RestrictedRightsManager.get_hiddenonly_fields(roles,klass_object)

        Authorization.current_user = present_user if user && user.roles
      else
        restrict_read_only = klass_object.read_only
        restrict_create_only = klass_object.create_only
        restrict_update_only = klass_object.update_only
        restrict_hidden_only = klass_object.hidden_only
      end

      if action == "create" || action == "update" || action == "read"
        return true if !restrict_hidden_only.blank? && restrict_hidden_only.include?(field)
      end

      if action == "create" || action == "update"
        return true if !restrict_read_only.blank? && restrict_read_only.include?(field)
      end

      if action == "create"
        return true if !restrict_update_only.blank? && restrict_update_only.include?(field)
      end

      if action == "update"
        return true if !restrict_create_only.blank? && restrict_create_only.include?(field)
      end
      return false
    end

  end
end

