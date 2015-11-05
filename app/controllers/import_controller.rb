# -*- encoding : utf-8 -*-
class ImportController < ApplicationController
  before_action :authenticate_user! ## for DEVISE
  
  ## Internal libraries ##
  require 'ImportLogic'
  
  ## Resource Actions ##
  def new
    @import_title = "Importar CSV"
  end
  
  def create
    file = params[:file]
    begin
      if file.blank?
        flash[:error] = "Ningún file selecionado."
        redirect_to action: 'new', status: 303 
      elsif file.headers['Content-Type: text/csv'] or 
          file.headers['Content-Type: application/vnd.ms-excel']
        # Creates Actors:
        updater = ProgressBarUpdater.new
        importer = ImportLogic.new(updater)
        # Sends file to import actor:
        importer.import_csv(file)
        result = importer.exit_status
        importer.terminate #shutdown actor
        # updater.terminate # Already shutdown by importer
        
        flash[:notice] = "#{result[:total_lines]} Records Importados en: #{result[time]} segundos"
        redirect_to debts_path
      else
        flash[:error] = "No es un CSV"
        flash[:notice] = file.headers
        redirect_to action: 'new', status: 303   
      end
    end
  end
  
  
end
