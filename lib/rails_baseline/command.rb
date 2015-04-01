require "thor"

module RailsBaseline
  class Command < Thor
  	include Thor::Actions
    desc "new APP_NAME", "create a new Rails app"
    def new(name)
      run_template(name)
    end

    desc "list", "list all recipes"
    def list
      list_all_recipes
    end

    no_tasks do
      def cyan; "\033[36m" end
      def clear; "\033[0m" end
      def bold; "\033[1m" end
      def red; "\033[31m" end
      def green; "\033[32m" end
      def yellow; "\033[33m" end

      def run_template(name)
        puts "#{bold}Generating and Running Template..."
        template_path = File.join( File.dirname(__FILE__), 'template.rb' )
  			file = File.open( template_path )
        system "rails new #{name} -m #{file.path} --skip-bundle"
      end
        
      def list_all_recipes
        puts "#{bold}#{yellow}All recipes in order:"
        puts "#{clear}1. Deflator(non configurable)"
        puts "2. SMTP Configurations(non configurable)"
        puts "3. Rails Config"
        puts "4. RSpec test suite(non configurable)"
        puts "5. Database(Mongoid, MySQL, Postgresql, SQLite)"
        puts "6. Devise"
        puts "7. ActiveAdmin"
        puts "8. Application views(non configurable)"
        puts "9. SASS(non configurable)"
        puts "10. Bootstrap"
        puts "11. Git(non configurable)"
      end
    end
  end
end