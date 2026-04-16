module TenantingHelper
  def tenanted_action_cable_meta_tag
    tag "meta",
        name: "action-cable-url",
        content: "#{request.script_name}#{ActionCable.server.config.mount_path}"
  end
end
