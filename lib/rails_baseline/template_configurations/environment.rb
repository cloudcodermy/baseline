def deflator
  insertion_text = <<-TEXT
  \n
      config.middleware.use Rack::Deflater
  TEXT

  inject_into_file "config/application.rb", insertion_text, :after => "# config.i18n.default_locale = :de"
end