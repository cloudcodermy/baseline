# >----------------------------[ Initial Setup ]------------------------------<

# @recipes = ["database", "mongoid", "devise", "activeadmin", "git", "sass"] 
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

# >-----------------------[ Deflator and Autoloads ]--------------------------<
@current_recipe = "deflator"

insertion_text = <<-TEXT
\n
    config.middleware.use Rack::Deflater
TEXT

inject_into_file "config/application.rb", insertion_text, :after => "# config.i18n.default_locale = :de"

# >--------------------------------[ Email Settings ]---------------------------------<
@current_recipe = "smtp"

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

# >--------------------------------[ Rails Config ]---------------------------------<

@current_recipe = "rails_config"
@before_configs["rails_config"].call if @before_configs["rails_config"]
say_recipe 'Rails Config'

gem 'rails_config', '0.5.0.beta1'

after_bundler do
  generate 'rails_config:install'
end

# >--------------------------------[ Quiet Assets ]---------------------------------<

@current_recipe = "quiet_assets"
@before_configs["quiet_assets"].call if @before_configs["quiet_assets"]
say_recipe 'Quiet Assets'

gem 'quiet_assets', group: :development

# >--------------------------------[ RSpec ]---------------------------------<
@current_recipe = "rspec"
@before_configs["rspec"].call if @before_configs["rspec"]
say_recipe 'RSpec'

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

# Disable activeadmin for mongoid at the moment
if config['database'] != "mongoid"
  @current_recipe = "activeadmin"
  @before_configs["activeadmin"].call if @before_configs["activeadmin"]
  say_recipe 'Active Admin'

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

# >--------------------------------[ CanCanCan ]---------------------------------<

@current_recipe = "cancancan"
@before_configs["cancancan"].call if @before_configs["cancancan"]
say_recipe 'CanCanCan'

gem 'cancancan', '~> 1.10'

after_bundler do
  generate "cancan:ability"
end

# >-----------------------------[ Decent Exposure ]------------------------------<

@current_recipe = "decent_exposure"
@before_configs["decent_exposure"].call if @before_configs["decent_exposure"]
say_recipe 'Decent Exposure'

gem 'decent_exposure', '~> 2.3.2'

decent_exposure_strong_parameters = <<-TEXT
  \n
  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end
TEXT

after_bundler do
  inject_into_file "app/controllers/application_controller.rb", decent_exposure_strong_parameters, :after => "protect_from_forgery with: :exception"
end

# >--------------------------------[ Paperclip ]---------------------------------<

@current_recipe = "paperclip"
@before_configs["paperclip"].call if @before_configs["paperclip"]
say_recipe 'Paperclip'

if config['database'] == "mongoid"
  gem "mongoid-paperclip", :require => "mongoid_paperclip"
  gem 'aws-sdk', '~> 1.3.4'
else
  gem "paperclip", "~> 4.2"
end

# >--------------------------------[ State Machines ]---------------------------------<

@current_recipe = "state_machines"
@before_configs["state_machines"].call if @before_configs["state_machines"]
say_recipe 'State Machines'

if config['database'] == "mongoid"
  gem 'state_machines-mongoid'
else
  gem 'state_machines-activerecord'
end

# >--------------------------------[ Delayed Job ]---------------------------------<

@current_recipe = "delayed_job"
@before_configs["delayed_job"].call if @before_configs["delayed_job"]
say_recipe 'Delayed Job'

if config['database'] == "mongoid"
  gem 'delayed_job_mongoid'
else
  gem 'delayed_job_active_record'
  after_bundler do
    generate "delayed_job:active_record"
  end
end

delayed_job_config = <<-TEXT
  \n
    config.active_job.queue_adapter = :delayed_job
TEXT

after_bundler do
  inject_into_file "config/application.rb", delayed_job_config, :after => "# config.i18n.default_locale = :de"
end
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
  <!-- Google Tag Manager -->
  <noscript><iframe src="//www.googletagmanager.com/ns.html?id=GTM-XXXXXX"
  height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
  <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
  new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
  j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
  '//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
  })(window,document,'script','dataLayer','GTM-XXXXXX');</script>
  <!-- End Google Tag Manager -->

  <%= yield %>
  
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
</body>
</html>
TEXT

after_bundler do
  remove_file 'app/views/layouts/application.html.erb'
  create_file 'app/views/layouts/application.html.erb', application_html_file
  say_wizard "--------------------------- APPLICATION VIEWS -----------------------------"
  say_wizard "|Please change your GTM, title and meta settings in application.html.erb. |"
  say_wizard "---------------------------------------------------------------------------"
end

# >--------------------------------[ Paranoia ]-----------------------------------<

@current_recipe = "paranoia"
@before_configs["paranoia"].call if @before_configs["paranoia"]
say_recipe 'Paranoia'

gem "paranoia", "~> 2.0"

# >------------------------[ Better Errors and Hirb ]-----------------------------<

@current_recipe = "better_errors"
@before_configs["better_errors"].call if @before_configs["better_errors"]
say_recipe 'Better Errors and Hirb'

gem_group :development do
  gem "better_errors"
  gem "hirb"
end

# >-------------------------------[ Setup SASS ]----------------------------------<

@current_recipe = "sass"
@before_configs["sass"].call if @before_configs["sass"]
say_recipe 'SASS'

after_bundler do
  copy_file 'app/assets/stylesheets/application.css', 'app/assets/stylesheets/application.css.scss'
  remove_file 'app/assets/stylesheets/application.css'
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

use_bootstrap = @configs[@current_recipe] = yes_wizard?("Install and configure Bootstrap?")
if use_bootstrap
  gem 'bootstrap-sass', '~> 3.3.4'

  after_bundler do
    append_to_file 'app/assets/stylesheets/application.css.scss', config_lines
    insert_into_file "app/assets/javascripts/application.js", :after => %r{//= require +['"]?jquery_ujs['"]?} do
      "\n//= require bootstrap-sprockets"
    end
    create_file 'app/views/shared/_messages.html.erb', flash_message
  end
end

# >--------------------------[ jQuery Validation ]-----------------------------<

@current_recipe = "jquery-validation-rails"
@before_configs["jquery-validation-rails"].call if @before_configs["jquery-validation-rails"]
say_recipe 'jQuery Validation Rails'

gem "jquery-validation-rails"

after_bundler do
  insert_into_file "app/assets/javascripts/application.js", :after => %r{//= require +['"]?jquery_ujs['"]?} do
    "\n//= require jquery.validate\n//= require jquery.validate.additional-methods"
  end
end

# >--------------------------[ jQuery dataTables ]-----------------------------<

@current_recipe = "jquery-datatables-rails"
@before_configs["jquery-datatables-rails"].call if @before_configs["jquery-datatables-rails"]
say_recipe 'jQuery dataTables Rails'

gem 'jquery-datatables-rails', '~> 3.2.0'

datatable_config_lines_bootstrap = <<-TEXT
@import "dataTables/bootstrap/3/jquery.dataTables.bootstrap";
TEXT

datatable_config_lines_non_bootstrap = <<-TEXT
@import "dataTables/jquery.dataTables";
TEXT

after_bundler do
  after_bundler do
    if @configs["bootstrap"] # if bootstrap configuration is true
      say_wizard "Generating Bootstrap 3 dataTables"
      append_to_file 'app/assets/stylesheets/application.css.scss', datatable_config_lines_bootstrap
      insert_into_file "app/assets/javascripts/application.js", :after => %r{//= require +['"]?jquery_ujs['"]?} do
        "\n//= require dataTables/jquery.dataTables\n//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap"
      end
    else
      append_to_file 'app/assets/stylesheets/application.css.scss', datatable_config_lines_non_bootstrap
      insert_into_file "app/assets/javascripts/application.js", :after => %r{//= require +['"]?jquery_ujs['"]?} do
        "\n//= require dataTables/jquery.dataTables\n//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap"
      end
    end
  end
end

# >-----------------------------[ Kaminari ]------------------------------<

@current_recipe = "kaminari"
@before_configs["kaminari"].call if @before_configs["kaminari"]
say_recipe 'Kaminari'

gem 'kaminari'

after_bundler do
  generate "kaminari:views bootstrap3" if @configs["bootstrap"]
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
