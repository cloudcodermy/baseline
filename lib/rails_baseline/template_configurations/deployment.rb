def deployment
  @configs['deployment'] = multiple_choice("Which deployment method are you using?", [["Heroku", "heroku"], ["Capistrano", "capistrano"], ["Engine Yard", "engineyard"], ["No Recipe", "none"]])

  unicorn_config =<<-TEXT
  # config/unicorn.rb
  worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
  timeout 15
  preload_app true

  before_fork do |server, worker|
    Signal.trap 'TERM' do
      puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
      Process.kill 'QUIT', Process.pid
    end

      defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!
  end

  after_fork do |server, worker|
    Signal.trap 'TERM' do
      puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
    end

    defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection
  end
  TEXT

  ey_config = <<-TEXT
  ---
  # This is all you need for a typical rails application.
  defaults:
    migrate: true
    migration_command: rake db:migrate
    precompile_assets: true
  TEXT

  case @configs['deployment']
  when "heroku"
    gem 'unicorn'
    gem 'rails_12factor', group: :production

    after_bundler do
      create_file "config/unicorn.rb", unicorn_config
      create_file "Procfile", "web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb"
    end
  when "capistrano"
    gem 'capistrano'

    after_bundler do
      run "bundle exec cap install"
    end

  when "engineyard"
    after_bundler do
      create_file "config/ey.yml", ey_config
    end
  end
end