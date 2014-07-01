# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  $('.datepicker').datepicker({ dateFormat: "yy-mm-dd",
  beforeShow: (input, instance)->
    setTimeout ->
      instance.dpDiv.css({'z-index': 100})
   })
  # $('#ui-datepicker-div').css({ 'z-index':100 })
  # $('.datepicker').datepicker({ showAnim: 'slideDown'})