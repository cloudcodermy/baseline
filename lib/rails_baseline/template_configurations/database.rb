def database
  database_option = "activerecord"

  config = {}
  config['database'] = multiple_choice("Which database are you using?", [["MongoDB", "mongoid"], ["MySQL", "mysql"], ["PostgreSQL", "postgresql"], ["SQLite", "sqlite3"]]) if true && true unless config.key?('database')
  database_option = config['database']
  @configs[@current_recipe] = database_option


  if config['database']
      say_wizard "Configuring '#{config['database']}' database settings..."
      @options = @options.dup.merge(:database => config['database'])
      say_recipe "Currently selected as #{database_option}"
    if database_option != "mongoid"
      config['auto_create'] = yes_wizard?("Automatically create database with default configuration?") if true && true unless config.key?('auto_create')
      gem gem_for_database[0]
      template "config/databases/#{@options[:database]}.yml", "config/database.yml.new"
      run 'mv config/database.yml.new config/database.yml'
    else
      database_option = "mongoid"
      gem 'mongoid'
    end
  end

  after_bundler do
    if database_option == "activerecord"
      rake "db:create" if config['auto_create']
    elsif database_option == "mongoid"
      generate 'mongoid:config'
    end
  end
end 