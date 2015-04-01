# >----------------------------[ Initial Setup ]------------------------------<

@recipes = ["database", "mongoid", "devise", "activeadmin", "git", "sass"] 
@database_choice = nil

def recipes; @recipes end
def recipe?(name); @recipes.include?(name) end

def say_custom(tag, text); say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}" end
def say_recipe(name); say "\033[1m\033[36m" + "recipe".rjust(10) + "\033[0m" + "  Running #{name} recipe..." end
def say_wizard(text); say_custom(@current_recipe || 'wizard', text) end

def ask_wizard(question)
  ask "\033[1m\033[30m\033[46m" + (@current_recipe || "prompt").rjust(10) + "\033[0m\033[36m" + "  #{question}\033[0m"
end

def yes_wizard?(question)
  answer = ask_wizard(question + " \033[33m(y/n)\033[0m")
  case answer.downcase
    when "yes", "y"
      true
    when "no", "n"
      false
    else
      yes_wizard?(question)
  end
end

def no_wizard?(question); !yes_wizard?(question) end

def multiple_choice(question, choices)
  say_custom('question', question)
  values = {}
  choices.each_with_index do |choice,i| 
    values[(i + 1).to_s] = choice[1]
    say_custom (i + 1).to_s + ')', choice[0]
  end
  answer = ask_wizard("Enter your selection:") while !values.keys.include?(answer)
  values[answer]
end

@current_recipe = nil
@configs = {}

@after_blocks = []
def after_bundler(&block); @after_blocks << [@current_recipe, block]; end
@after_everything_blocks = []
def after_everything(&block); @after_everything_blocks << [@current_recipe, block]; end
@before_configs = {}
def before_config(&block); @before_configs[@current_recipe] = block; end

# >---------------------------[ ActiveRecord/Mongoid ]----------------------------<

@current_recipe = "database"
@before_configs["activerecord"].call if @before_configs["activerecord"]
say_recipe 'Database'

database_option = "activerecord"

config = {}
config['database'] = multiple_choice("Which database are you using?", [["MongoDB", "mongoid"], ["MySQL", "mysql"], ["PostgreSQL", "postgresql"], ["SQLite", "sqlite3"]]) if true && true unless config.key?('database')
database_option = config['database']
@configs[@current_recipe] = config


if config['database']
    say_wizard "Configuring '#{config['database']}' database settings..."
    @options = @options.dup.merge(:database => config['database'])
    say_recipe "Currently selected as #{database_option}"
  if database_option != "mongoid"
    config['auto_create'] = yes_wizard?("Automatically create database with default configuration?") if true && true unless config.key?('auto_create')
    gem gem_for_database
    template "config/databases/#{@options[:database]}.yml", "config/database.yml.new"
    run 'mv config/database.yml.new config/database.yml'
  else
    database_option = "mongoid"
    gem 'mongoid',  '~> 4.0.0'
  end
end

after_bundler do
  if database_option == "activerecord"
    rake "db:create" if config['auto_create']
  elsif database_option == "mongoid"
    generate 'mongoid:config'
  end
end

# >--------------------------------[ Devise ]---------------------------------<

@current_recipe = "devise"
@before_configs["devise"].call if @before_configs["devise"]
say_recipe 'Devise'

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

# >--------------------------------[ Active Admin ]---------------------------------<

@current_recipe = "activeadmin"
@before_configs["activeadmin"].call if @before_configs["activeadmin"]
say_recipe 'Active Admin'

gem 'activeadmin', github: 'activeadmin'

if yes_wizard?("Skip Users?")
  after_bundler do
    generate "active_admin:install --skip-users" # skips Devise install
  end
else
  model_name = ask_wizard("Enter the model name of AA. Leave it blank to default as AdminUser.")
  after_bundler do
    if model_name.present?
      generate "active_admin:install #{model_name}"         # creates / edits the class for use with Devise
    else
      generate "active_admin:install"              # creates the AdminUser class
    end
  end
end

# >-------------------------------[ Setup SASS ]----------------------------------<

@current_recipe = "sass"
@before_configs["sass"].call if @before_configs["sass"]
say_recipe 'SASS'

after_bundler do
  copy_file 'app/assets/stylesheets/application.css', 'app/assets/stylesheets/application.css.scss'
  remove_file 'app/assets/stylesheets/application.css'
end

@current_recipe = nil

# >---------------------------[ Application Views ]------------------------------<
@current_recipe = "application"
@before_configs["application"].call if @before_configs["application"]
say_recipe 'Application Views'

application_html_file = <<-TEXT
<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Title</title>
  <meta name="description" content="This is the description">
  <meta content="width=device-width, initial-scale=1.0" name="viewport">

  <meta property="og:title" content="Title" />
  <meta property="og:type" content="article" />
  <meta property="og:url" content="<%= root_url %>" />
  <meta property="og:image" content="<%= root_url %>/logo.png" />
  <meta property="og:description" content="This is the description" />

  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <%= csrf_meta_tags %>
  <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->
</head>
<body>
  <!--[if lt IE 7]>
    <p class="browsehappy">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> to improve your experience.</p>
  <![endif]-->
  <%= yield %>
  
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
</body>
</html>
TEXT

after_bundler do
  remove_file 'app/views/layouts/application.html.erb'
  create_file 'app/views/layouts/application.html.erb', application_html_file
  say_wizard "------------------------ APPLICATION VIEWS --------------------------"
  say_wizard "|Please change your title and meta settings in application.html.erb.|"
  say_wizard "---------------------------------------------------------------------"
end

# >--------------------------------[ Bootstrap ]---------------------------------<

@current_recipe = "bootstrap"
@before_configs["bootstrap"].call if @before_configs["bootstrap"]
say_recipe 'Bootstrap Front End'

config_lines = <<-TEXT
@import "bootstrap-sprockets";
@import "bootstrap";
TEXT

flash_message = <<-TEXT
<% flash.each do |name, msg| %>
  <% 
    code = "warning"
    desc = "Oh!"
    case name.to_s 
    when "notice"
      code = "success"
      desc = "Done!" 
    when "error"
      code = "danger"
      desc = "Alert!"
    when "info"
      code = "info"
      desc = "Info!"
    end
  %>      
  <div class="alert alert-<%= code %>">
      <button type="button" class="close" data-dismiss="alert">x</button>
      <strong><%= desc %></strong> <%= msg %>
  </div> 
<% end %>
TEXT

if yes_wizard?("Install and configure Bootstrap?")
  gem 'bootstrap-sass', '~> 3.3.4'
  after_bundler do
    append_to_file 'app/assets/stylesheets/application.css.scss', config_lines
    insert_into_file "app/assets/javascripts/application.js", :after => %r{//= require +['"]?jquery_ujs['"]?} do
      "\n//= require bootstrap-sprockets"
    end
    create_file 'app/views/shared/_messages.html.erb', flash_message
  end
end

# >--------------------------------[ Rails Config ]---------------------------------<

@current_recipe = "rails_config"
@before_configs["rails_config"].call if @before_configs["rails_config"]
say_recipe 'Rails Config'

gem 'rails_config', '0.5.0.beta1'

after_bundler do
  generate 'rails_config:install'
end

# >--------------------------------[ RSpec ]---------------------------------<
@current_recipe = "rspec"
@before_configs["rspec"].call if @before_configs["rspec"]
say_recipe 'RSpec'

gem 'rails_apps_testing', :group => :development
gem 'rspec-rails', :group => [:development, :test]
gem 'spring-commands-rspec', :group => :development
gem 'factory_girl_rails', :group => [:development, :test]
gem 'faker', :group => [:development, :test]
gem 'capybara', :group => :test
gem 'database_cleaner', :group => :test
gem 'launchy', :group => :test
gem 'selenium-webdriver', :group => :test

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

# >-----------------------[ Deflator and Autoloads ]--------------------------<
@current_recipe = "deflator"

insertion_text = <<-TEXT
\n
    config.middleware.use Rack::Deflater
TEXT

inject_into_file "config/application.rb", insertion_text, :after => "# config.i18n.default_locale = :de"

# >--------------------------------[ Email Settings ]---------------------------------<
@current_recipe = "email"

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
  say_wizard "| Please change your settings in development.rb                  |"
  say_wizard "| and production.rb                                              |"
  say_wizard "------------------------------------------------------------------"
end

# >----------------------------------[ Git ]----------------------------------<

@current_recipe = "git"
@before_configs["git"].call if @before_configs["git"]
say_recipe 'Git'

after_everything do
  git :init
  git :add => '.'
  git :commit => '-m "Initial commit"'
end

# >-----------------------------[ Run Bundler ]-------------------------------<
@current_recipe = "bundler"

say_wizard "Running Bundler install. This will take a while."
run 'bundle install'
say_wizard "Running after Bundler callbacks."
@after_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}

@current_recipe = nil
say_wizard "Running after everything callbacks."
@after_everything_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}

@current_recipe = nil
say_wizard "==================================FINISH PROCESS================================="
