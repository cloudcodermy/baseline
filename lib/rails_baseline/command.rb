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
        puts "#{yellow}All recipes in order:#{clear}"
        recipes_list_path = File.join( File.dirname(__FILE__), 'recipes.txt' )
        File.open(recipes_list_path, "r").each_line.with_index do |line, index|
          puts "#{index+1}. #{line}"
        end
      end
    end
  end
end