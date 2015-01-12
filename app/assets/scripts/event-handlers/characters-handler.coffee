@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Characters = (socket, viewModel) ->
  uncheckCharacters = (characterSelector, type, max) ->
    while $(".character-#{type}:checked").length > max and $(characterSelector).length > 0
      $(characterSelector).last().prop "checked", false
  
  uncheckNormalCharacterOverflow = ->
    uncheckCharacters ".character-normal.character-good:checked", "good",
      viewModel.character().numGood()
    uncheckCharacters ".character-normal.character-bad:checked", "bad",
      viewModel.character().numBad()
    uncheckCharacters "#character-oberon:checked", "bad",
      viewModel.character().numBad()
  
  enableCreateCharacterBtn = ->
    numCharacters = $(".character-type:checked").length
    numPlayers = viewModel.character().count()
    $("#create-characters-btn").prop "disabled", numCharacters isnt numPlayers
  
  registerDependentCharacterListener = (instigator, dependents, changeFn) ->
    $("#character-#{instigator}").change ->
      for dependent, type of dependents
        if $(this).is(":checked")
          if type in ["check", "both"]
            $("#character-#{dependent}").prop "checked", true
        else if type in ["uncheck", "both"]
          $("#character-#{dependent}").prop "checked", false
      uncheckNormalCharacterOverflow()
      changeFn() if changeFn?
  
  socket.on "show_new_characters", (data) ->
    viewModel.player().current data.currentPlayer
    viewModel.game().current data.currentGame
    viewModel.game().players data.gamePlayers
    viewModel.character().stats data.characterStats
    viewModel.nav().currentPage "new_characters"
    
    $(".character-normal").change uncheckNormalCharacterOverflow
    registerDependentCharacterListener "merlin",
      assassin: "both"
      mordred: "uncheck"
      morgana: "uncheck"
      percival: "uncheck"
    registerDependentCharacterListener "assassin",
      merlin: "both"
      mordred: "uncheck"
      morgana: "uncheck"
      percival: "uncheck"
    registerDependentCharacterListener "mordred",
      { merlin: "check", assassin: "check" }, ->
        uncheckCharacters "#character-morgana:checked", "bad",
          viewModel.character().numBad()
    registerDependentCharacterListener "morgana",
      { merlin: "check", assassin: "check", percival: "check" }, ->
        uncheckCharacters "#character-mordred:checked", "bad",
          viewModel.character().numBad()
    registerDependentCharacterListener "percival",
      { merlin: "check", assassin: "check", morgana: "uncheck" }
    $("#character-oberon").change ->
      if $(this).is(":checked")
        uncheckNormalCharacterOverflow()
        $(this).prop "checked", true # recheck oberon if unchecked
        uncheckCharacters "#character-morgana:checked", "bad",
          viewModel.character().numBad()
        uncheckCharacters "#character-mordred:checked", "bad",
          viewModel.character().numBad()
    $(".character-type").change enableCreateCharacterBtn
