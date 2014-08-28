# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

reset_fonts = -> $('body').css('font-family', 'Arial')
# $('#reset_fonts').on('mouseover', reset_fonts())

#Compatiblity Mode in IE tends to be turned on for intranets
if navigator.userAgent.indexOf('compatible') > -1
  alert "You have Compatibility Mode turned on in IE. Please turn it off."