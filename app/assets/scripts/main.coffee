socket = io.connect $('meta[name="ws-url"]').attr("content"), secure: true
viewModel = new Avalon.Main socket
Avalon.EventHandlers.Main socket, viewModel

$ ->
  $(".no-js").removeClass "no-js"
  ko.applyBindings viewModel
