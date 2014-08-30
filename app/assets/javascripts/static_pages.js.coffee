# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

reset_fonts = -> $('body').css('font-family', 'Arial')
# $('#reset_fonts').on('mouseover', reset_fonts())

#Compatiblity Mode in IE tends to be turned on for intranets
if navigator.userAgent.indexOf('compatible') > -1
  alert "Tiene el modulo de compatibilidad prendido en IE, la navegación no funcionará. Por favor apague el modulo. Vaya a el ícono de una rueda dentada y seleccione 'Compatibility View Settings'"
  $('.container').prepend("<div class='alert alert-danger'> IE Compatibilty Turned On. Please turn it off.</div>")

