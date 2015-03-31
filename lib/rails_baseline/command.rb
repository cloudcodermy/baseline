require "thor"

module RailsBaseline
  class Command < Thor
  	include Thor::Actions
    desc "new APP_NAME", "create a new Rails app"

    def new(name)
      run_template(name)
    end

    no_tasks do
      def cyan; "\033[36m" end
      def clear; "\033[0m" end
      def bold; "\033[1m" end
      def red; "\033[31m" end
      def green; "\033[32m" end
      def yellow; "\033[33m" end

      def run_template(name)
        puts
        puts
        puts "#{bold}Generating and Running Template..."
        puts
        template_path = File.join( File.dirname(__FILE__), 'template.rb' )
  			file = File.open( template_path )
        system "rails new #{name} -m #{file.path}"
      end
    end
  end
end