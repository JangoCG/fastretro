module UsersHelper
  def role_display_name(user)
    I18n.t("roles.#{user.role}", default: I18n.t("roles.member"))
  end
end
