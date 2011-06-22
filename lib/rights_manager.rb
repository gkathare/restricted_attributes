require "active_model"

class RightsManager

  cattr_accessor :rights, :version
  attr_accessor :obj_name, :role_name

  def initialize(attribs={})
    self.obj_name=attribs[:obj_name]
    self.role_name=attribs[:role_name]
  end

  def self.get_readonly_fields(roles, obj)
    resp=Rails.cache.fetch([RightsManager.version,roles.to_s,obj.class.name,"read_only_fields"].join("_")){
    RightsManager.get_ro_fields(roles, obj)
    }
    resp
  end

  def self.get_createonly_fields(roles, obj)
    resp=Rails.cache.fetch([RightsManager.version,roles.to_s,obj.class.name,"create_only_fields"].join("_")){
    RightsManager.get_co_fields(roles, obj)
    }
    resp
  end

  def self.get_updateonly_fields(roles, obj)
    resp=Rails.cache.fetch([RightsManager.version,roles.to_s,obj.class.name,"update_only_fields"].join("_")){
    RightsManager.get_uo_fields(roles, obj)
    }
    resp
  end

  def self.get_ro_fields(roles, obj)
    resp=Rails.cache.fetch([RightsManager.version,roles.to_s,obj.class.name,"read_only_fields"].join("_")){
    obj_name=obj.class.name.underscore.downcase

      # get read only default for all objects
      begin
        default_ro_fields = obj.read_only || []
      rescue
        default_ro_fields = []
      end

      begin
      	permitted_change = []
        roles.each do |role_name|
        	if RightsManager.rights[role_name] && RightsManager.rights[role_name][obj_name]
            permitted_change |= RightsManager.rights[role_name][obj_name][:permit_to] || []
          end
        end
      rescue
        permitted_change = []
      end
      permitted_changes = permitted_change.collect{|p| p.to_s}
      ro_fields = default_ro_fields - permitted_changes }
    resp
  end

  def self.get_co_fields(roles, obj)
    resp=Rails.cache.fetch([RightsManager.version,roles.to_s,obj.class.name,"create_only_fields"].join("_")){
    obj_name=obj.class.name.underscore.downcase

      # get create only defaults for all objects
      begin
        default_co_fields = obj.create_only || []
      rescue
        default_co_fields = []
      end

      begin
      	permitted_updates = []
        roles.each do |role_name|
        	if RightsManager.rights[role_name] && RightsManager.rights[role_name][obj_name]
            permitted_updates |= RightsManager.rights[role_name][obj_name][:permit_to] || []
          end
        end
      rescue
        permitted_updates = []
      end
      permit_updates = permitted_updates.collect{|p| p.to_s}
      co_fields = default_co_fields - permit_updates }
    resp
  end

  def self.get_uo_fields(roles, obj)
    resp=Rails.cache.fetch([RightsManager.version,roles.to_s,obj.class.name,"update_only_fields"].join("_")){
    obj_name=obj.class.name.underscore.downcase

      # get update only defaults for all objects
      begin
        default_uo_fields = obj.update_only || []
      rescue
        default_uo_fields = []
      end

      begin
      	permitted_create = []
        roles.each do |role_name|
        	if RightsManager.rights[role_name] && RightsManager.rights[role_name][obj_name]
            permitted_create |= RightsManager.rights[role_name][obj_name][:permit_to] || []
          end
        end
      rescue
        permitted_updates = []
      end
      permitted_creates = permitted_create.collect{|p| p.to_s}
      co_fields = default_uo_fields - permitted_creates }
    resp
  end

  def self.load_config
    RightsManager.rights = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/permissions.yml"))
  end

  def self.get_roles(user,obj)
    roles=user.roles
    return (roles.blank?) ? [] : roles.collect {|role| role.title }
  end
end

RightsManager.load_config
RightsManager.version=Time.now.utc.to_i





