socket = io.connect()
viewModel = new Avalon.Main socket
Avalon.EventBindings socket, viewModel

$ ->
  $('.no-js').removeClass 'no-js'
  ko.applyBindings viewModel
