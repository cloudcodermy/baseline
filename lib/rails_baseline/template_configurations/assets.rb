def quiet_assets
  gem 'quiet_assets', group: :development
end

def sass
  after_bundler do
    copy_file 'app/assets/stylesheets/application.css', 'app/assets/stylesheets/application.css.scss'
    remove_file 'app/assets/stylesheets/application.css'
  end
end

def bootstrap
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
end

def font_awesome
  font_awesome_configs = <<-TEXT
  @import "font-awesome-sprockets";
  @import "font-awesome";
  TEXT

  gem 'font-awesome-sass', '~> 4.3.0'

  after_bundler do
    append_to_file 'app/assets/stylesheets/application.css.scss', font_awesome_configs
  end
end