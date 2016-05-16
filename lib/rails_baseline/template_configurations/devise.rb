def devise
  gem 'devise'

  after_bundler do
    generate 'devise:install'
  end

  if yes_wizard?("Generate Devise model?")
    model_name = ask_wizard("Enter the model name for Devise. Leave it blank to default as User.")
    after_bundler do
      if model_name.present?
        generate "devise #{model_name}"
      else
        generate "devise user"
      end
    end
  end
end