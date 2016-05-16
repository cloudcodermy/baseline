def rails_config
  gem 'rails_config'

  after_bundler do
    generate 'rails_config:install'
  end
end