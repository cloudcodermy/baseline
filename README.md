# Rails 4 Baseline
[![Gem Version](https://badge.fury.io/rb/rails_baseline.svg)](http://badge.fury.io/rb/rails_baseline)

This gem is a wrapper of a Rails Applications Template to create a new Rails 4.2 application based on the normal practices in [cloudcoder.com.my](http://cloudcoder.com.my). Just go through a simple wizard to get all the gems set and you'll be good to proceed with migrations and start coding your project.

This gem is heavily based on [rails_wizard](https://github.com/intridea/rails_wizard) for the overall idea of the gem and refers to [rails-composer](https://github.com/RailsApps/rails-composer) for the code organization.

## Compatibility

This gem is tested on Rails 4.2 and meant to build new Rails 4.2 app, it is unknown whether the gem is working fine in Rails 4.0.x and 4.1.x or not. The only difference at the moment is a configuration of ActiveJob for adding `Delayed Job` as the background worker.

## Installation

Please don't include this gem into Gemfile.

    $ gem install rails_baseline

## Usage

#### List out all available recipes:

    $ rails_baseline list

The list is available to view through lib/recipes.txt as well.

#### Create a new Rails app:

    $ rails_baseline new APP_NAME

Please replace APP_NAME with your new Rails app name.

#### Post-Wizard Configuration

After the wizard, please configure these files according to your title, details and credentials:

1. SMTP Settings: `config/environments/development.rb` and `config/environments/production.rb`
2. Application Layout: `app/views/layouts/application.html.erb`
3. Devise initializer, modules and migration(refer to [https://github.com/plataformatec/devise](https://github.com/plataformatec/devise) for more information)
4. ActiveAdmin initializer and migration(refer to [https://github.com/activeadmin/activeadmin](https://github.com/activeadmin/activeadmin) for more information)

and run migration for the pending migration files:

	$ rake db:create
	$ rake db:migrate

## Changelog

1. 0.0.5 - Executable file
2. 0.1.0 - Rearrange wizard orders and order listing
3. 0.1.1 - Added jQuery Validation, CanCanCan and Google Tag Manager
3. 0.1.2 - Added Paranoia, Better Errors, Hirb and jQuery DataTables
4. 0.1.3 - Added Quiet Assets, Decent Exposure, Paperclip, State Machines, Delayed Job and Kaminari
5. 0.1.7 - Various fixes, and generate a static home page
6. 0.2.9 - Modularize code base, removed several gems

## Contributing

1. Fork it ( https://github.com/cloudcodermy/baseline/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Test codebase by `running bin/rails_baseline new <project_name>` to make sure it runs properly
4. Commit your changes (`git commit -am 'Add some feature'`) without committing test rails apps
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## License

Please refer to LICENSE.txt for more information