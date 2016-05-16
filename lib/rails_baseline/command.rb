require "thor"

module RailsBaseline
  class Command < Thor
  	include Thor::Actions
    desc "new APP_NAME", "create a new Rails app"
    method_option :version, type: :string, description: 'Optional Rails version', default: nil
    def new(name)
      run_template(name, options)
    end

    no_tasks do
      def cyan; "\033[36m" end
      def clear; "\033[0m" end
      def bold; "\033[1m" end
      def red; "\033[31m" end
      def green; "\033[32m" end
      def yellow; "\033[33m" end

      def run_template(name, options = {})
        puts "#{bold}Generating and Running Template..."
        template_path = File.join( File.dirname(__FILE__), 'template.rb' )
  			file = File.open( template_path )
        if options[:version]
          system "rails _#{options[:version]}_ new #{name} -m #{file.path} --skip-bundle"
        else
          system "rails new #{name} -m #{file.path} --skip-bundle"
        end
      end

    end
  end
end