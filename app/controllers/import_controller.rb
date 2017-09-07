# -*- encoding : utf-8 -*-

class ImportController < ApplicationController
  # include ActionController::Live # for sse (progress bar updatess)

  before_action :authenticate_user! ## for DEVISE

  ## Internal libraries ##
  # require 'ImportLogic'
  # require 'ImportSupport'
  require 'import_logic2'

  ## Resource Actions ##
  def new
    @import_title = 'Importar CSV'
  end

  def status
    #   response.headers['Content-Type'] = 'text/event-stream'
    #   sse = SSE.new(response.stream)
    #   begin
    #     # on_change is a method to listen to notifications
    #     ProgressBarUpdater.on_change do |data|
    #       sse.write(data)
    #     end
    #   rescue IOError
    #     # Client Disconnected
    #   ensure
    #     sse.close
    #   end
    render nothing: true
  end

  def create
    file = params[:file]
    begin
      if file.blank?
        flash[:error] = 'Ningún file selecionado.'
        redirect_to action: 'new', status: 303
      elsif file.headers['Content-Type: text/csv'] ||
            file.headers['Content-Type: application/vnd.ms-excel']

        ImportLogic2.import_csv(file)

        # flash[:notice] = "#{result[:total_lines]} Records Importados en: #{result[:time]} segundos"
        flash[:notice] = " Records Importados en:  segundos"
        redirect_to debts_path
      else
        flash[:error] = 'No es un CSV'
        flash[:notice] = file.headers
        redirect_to action: 'new', status: 303
      end
    end
  end
end
