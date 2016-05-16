def active_admin
  # Disable activeadmin for mongoid at the moment
  if @configs['database'] != "mongoid"
    gem 'activeadmin', github: 'activeadmin'

    if yes_wizard?("Active Admin with Users?(no to skip users)")
      model_name = ask_wizard("Enter the model name of ActiveAdmin. Leave it blank to default as AdminUser.")
      after_bundler do
        if model_name.present?
          generate "active_admin:install #{model_name}"
        else
          generate "active_admin:install"
        end
      end
    else
      after_bundler do
        generate "active_admin:install --skip-users"
      end
    end
  end
end