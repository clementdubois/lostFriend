xml.friend_list(:for_member => @user.login) do
  for o in @friends
    xml.friend do
      xml.first_name(o.first_name)
      xml.last_name(o.last_name)
      xml.email(o.email)
    end
  end
end