require "yaml"
require_relative "helper_functions"
require_relative "template_configurations"

recipes = [
  'deflator',
  'smtp',
  'rails_config',
  'quiet_assets',
  'test_suite',
  'database',
  'devise',
  'active_admin',
  'cancancan',
  'file_upload',
  'state_machines',
  'background_processor',
  'application_layout',
  'home_page',
  'paranoia',
  'debugger',
  'sass',
  'bootstrap',
 	'font_awesome',
 	'jquery_validation',
 	'jquery_datatable',
 	'kaminari',
 	'application_layout',
 	'home_page',
 	'deployment',
 	'git',
 	'bundler'
]

@database_choice = nil
@current_recipe = nil
@configs = {}
@after_blocks = []
@after_everything_blocks = []
@before_configs = {}

for recipe in recipes
	@current_recipe = recipe
	@before_configs[recipe].call if @before_configs[recipe]
	say_recipe recipe
	send(recipe)
end
