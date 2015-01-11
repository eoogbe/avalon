@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Characters = (socket, viewModel) ->
  uncheckCharacters = (type, max) ->
    characterSelector = ".character-#{type}:checked"
    specialCharactersSelector = "#character-merlin, #character-assassin, #character-mordred"
    while $(characterSelector).length > max
      $character = $(characterSelector).not(specialCharactersSelector).last()
      $character.prop "checked", false
  
  uncheckAllCharacterOverflow = ->
    uncheckCharacters "good", viewModel.character().numGood()
    uncheckCharacters "bad", viewModel.character().numBad()
  
  enableCreateCharacterBtn = ->
    numCharacters = $(".character-type:checked").length
    numPlayers = viewModel.character().count()
    $("#create-characters-btn").prop "disabled", numCharacters isnt numPlayers
  
  registerDependentCharacterListener = (instigator, dependents) ->
    $("#character-#{instigator}").change ->
      for dependent, type of dependents
        if $(this).is(":checked")
          if type in ["check", "both"]
            $("#character-#{dependent}").prop "checked", true
        else if type in ["uncheck", "both"]
          $("#character-#{dependent}").prop "checked", false
      uncheckAllCharacterOverflow()
  
  socket.on "show_new_characters", (data) ->
    viewModel.player().current data.currentPlayer
    viewModel.game().current data.currentGame
    viewModel.game().players data.gamePlayers
    viewModel.character().stats data.characterStats
    viewModel.nav().currentPage "new_characters"
    
    $(".character-normal").change uncheckAllCharacterOverflow
    registerDependentCharacterListener "merlin",
      { assassin: "both", mordred: "uncheck" }
    registerDependentCharacterListener "assassin",
      { merlin: "both", mordred: "uncheck" }
    registerDependentCharacterListener "mordred",
      { merlin: "check", assassin: "check" }
    $(".character-type").change enableCreateCharacterBtn
