require "active_model"

class RestrictedRightsManager

  cattr_accessor :rights, :version
  attr_accessor :obj_name, :role_name

  def initialize(attribs={})
    self.obj_name=attribs[:obj_name]
    self.role_name=attribs[:role_name]
  end

  def self.get_readonly_fields(roles, obj)
    resp=Rails.cache.fetch([RestrictedRightsManager.version,roles.to_s,obj.class.name,"read_only_fields"].join("_")){
    RestrictedRightsManager.get_restricted_fields(roles, obj, :readonly)
    }
    resp
  end

  def self.get_createonly_fields(roles, obj)
    resp=Rails.cache.fetch([RestrictedRightsManager.version,roles.to_s,obj.class.name,"create_only_fields"].join("_")){
    RestrictedRightsManager.get_restricted_fields(roles, obj, :createonly)
    }
    resp
  end

  def self.get_updateonly_fields(roles, obj)
    resp=Rails.cache.fetch([RestrictedRightsManager.version,roles.to_s,obj.class.name,"update_only_fields"].join("_")){
    RestrictedRightsManager.get_restricted_fields(roles, obj, :updateonly)
    }
    resp
  end

  def self.get_hiddenonly_fields(roles, obj)
    resp=Rails.cache.fetch([RestrictedRightsManager.version,roles.to_s,obj.class.name,"hidden_only_fields"].join("_")){
    RestrictedRightsManager.get_restricted_fields(roles, obj, :hiddenonly)
    }
    resp
  end


  def self.get_restricted_fields(roles, obj, access_type)
    resp=Rails.cache.fetch([RestrictedRightsManager.version,roles.to_s,obj.class.name,access_type.to_s].join("_")){
    #obj_name=obj.class.name.underscore.downcase

      
      # get default fields for all objects
      begin
        case access_type
          when :readonly
            default_fields = obj.read_only || []
          when :createonly
            default_fields = obj.create_only || []
          when :updateonly
            default_fields = obj.update_only || []
          when :hiddenonly
            default_fields = obj.hidden_only || []
          else
            default_fields = []
        end
      rescue
        default_fields = []
      end

      begin
      	permitted_fields, role_fields = [], []
        roles.each do |role_name|
        	if RestrictedRightsManager.rights[role_name]
            self_klass_name = obj.class.name.underscore.downcase
            base_klass_name = obj.class.base_class.name.underscore.downcase
            klass_name = RestrictedRightsManager.rights[role_name].include?(self_klass_name) ? self_klass_name : base_klass_name

            if RestrictedRightsManager.rights[role_name][klass_name]
              permitted_fields |= RestrictedRightsManager.rights[role_name][klass_name][:permit_to] || []
              role_fields |= RestrictedRightsManager.rights[role_name][klass_name][access_type] || []
            end
          end
        end
      rescue
        permitted_fields, role_fields = [], []
      end
      permitted_fields = permitted_fields.collect{|p| p.to_s}
      role_fields = role_fields.collect{|p| p.to_s}
      ro_fields = default_fields - permitted_fields
      ro_fields |= role_fields }
    resp
  end

  def self.load_config
    RestrictedRightsManager.rights = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/permissions.yml"))
  end

  def self.get_roles(user,obj)
    roles=user.roles
    return (roles.blank?) ? [] : roles.collect {|role| role.title }
  end
end





