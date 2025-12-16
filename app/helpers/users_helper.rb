module UsersHelper
  def role_display_name(user)
    case user.role
    when "owner" then "Owner"
    when "admin" then "Admin"
    else "Member"
    end
  end
end
