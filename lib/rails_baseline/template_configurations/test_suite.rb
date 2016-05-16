def test_suite
  gem_group :development do
    gem 'spring-commands-rspec'
    gem 'rails_apps_testing'
  end

  gem_group :development, :test do
    gem "rspec-rails"
    gem 'factory_girl_rails'
    gem 'faker'
  end

  gem_group :test do
    gem 'capybara'
    gem 'database_cleaner'
    gem 'launchy'
    gem 'selenium-webdriver'
  end

  rspec_text = <<-TEXT
  \n
      config.generators do |g|
        g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: true,
        request_specs: false
        g.fixture_replacement :factory_girl, dir: "spec/factories"
      end
  TEXT

  after_bundler do
    run 'bundle binstubs rspec-core'
    generate 'rspec:install'
    remove_dir 'test'

    inject_into_file "config/application.rb", rspec_text, :after => "# config.i18n.default_locale = :de"
  end	
end