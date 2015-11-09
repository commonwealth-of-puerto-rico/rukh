# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#TODO add code for progress bar updates here

source = new EventSource('/update')
source.onmessage = (event)->
  console.log event.data
  percentage = 25
  $('#progress-bar').style.width = percentage+'%'
  $('#progress-bar').html(event.data)
  