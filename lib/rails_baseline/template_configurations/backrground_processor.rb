def background_processor
  if @configs['database'] == "mongoid"
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
end