def jquery_validation
  gem "jquery-validation-rails"

  after_bundler do
    insert_into_file "app/assets/javascripts/application.js", :after => %r{//= require +['"]?jquery_ujs['"]?} do
      "\n//= require jquery.validate\n//= require jquery.validate.additional-methods"
    end
  end
end

def jquery_datatable
  gem 'jquery-datatables-rails', '~> 3.2.0'

  datatable_config_lines_bootstrap = <<-TEXT
  @import "dataTables/bootstrap/3/jquery.dataTables.bootstrap";
  TEXT

  datatable_config_lines_non_bootstrap = <<-TEXT
  @import "dataTables/jquery.dataTables";
  TEXT

  datatable_model = <<-TEXT
  class Datatable
    include ApplicationHelper
    delegate :params, :t, :h, :current_user, :link_to, to: :@view

    def initialize(view)
      @view = view
    end

    def as_json(options = {})
      {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: rows ? rows.count : 0,
        iTotalDisplayRecords: rows ? rows.total_entries : 0,
        aaData: data
      }
    end


    def rows
      @rows ||= fetch_datas
    end

    def fetch_datas
    end

    def page
      params[:iDisplayStart].to_i/per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def columns
      %w[]
    end

    def sort_column
      if params["iSortCol_0"].blank?
        columns[params[:order]["0"]["column"].to_i]
      else 
        columns[params["iSortCol_0"].to_i]    
      end
      
    end

    def sort_direction
      if params["iSortCol_0"].blank?
        params[:order]["0"]["dir"] == "desc" ? "desc" : "asc"
      else
        params["sSortDir_0"] == "desc" ? "desc" : "asc"
      end
      
    end
  end
  TEXT

  after_bundler do
    after_bundler do
      if @configs["bootstrap"] # if bootstrap configuration is true
        say_wizard "Generating Bootstrap 3 dataTables"
        append_to_file 'app/assets/stylesheets/application.css.scss', datatable_config_lines_bootstrap
        insert_into_file "app/assets/javascripts/application.js", :after => %r{//= require +['"]?jquery_ujs['"]?} do
          "\n//= require dataTables/jquery.dataTables\n//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap"
        end
      else
        append_to_file 'app/assets/stylesheets/application.css.scss', datatable_config_lines_non_bootstrap
        insert_into_file "app/assets/javascripts/application.js", :after => %r{//= require +['"]?jquery_ujs['"]?} do
          "\n//= require dataTables/jquery.dataTables\n//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap"
        end
      end
      create_file "app/models/datatable.rb", datatable_model
    end
  end
end