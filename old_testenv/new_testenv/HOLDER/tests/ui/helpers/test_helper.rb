def admin_login(username = @application_user, password = @application_password, admin_url = @admin)
  admin_logout(admin_url)
  page.open "#{admin_url}"
  if not page.text?("Logged in: #{username}")
    page.type "username", username
    page.type "password", password
    page.click "//input[@value='Log in']", :wait_for => :page
  end
end

def admin_logout(admin_url = @admin)
  page.open "#{admin_url}?id=login"
end

def iopro_login(username = @iopro_user, password = @iopro_password)
  iopro_logout
  page.open "/iopro"
  if not page.text? "Enter Spotlight Manager"
    page.type "login", username
    page.type "password", password
    page.click "//input[@value='Log in']", :wait_for => :page
  end
end

def iopro_logout
  page.open "/iopro/logout"
end
