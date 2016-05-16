def smtp
  email_configuration_text = <<-TEXT
  \n
    config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :enable_starttls_auto => true,
      :address              => "smtp.mandrillapp.com",
      :port                 => 587,
      :domain               => 'YOUR_DOMAIN',
      :user_name            => "USERNAME",
      :password             => "PASSWORD",
      :authentication       => :plain
    }
  TEXT
  
  after_bundler do
    inject_into_file 'config/environments/development.rb', email_configuration_text, :after => "config.assets.debug = true"
    inject_into_file 'config/environments/production.rb', email_configuration_text, :after => "config.active_support.deprecation = :notify"
    say_wizard "------------------------ EMAIL SETTINGS --------------------------"
    say_wizard "| Please change your email settings in development.rb            |"
    say_wizard "| and production.rb                                              |"
    say_wizard "------------------------------------------------------------------"
  end
end