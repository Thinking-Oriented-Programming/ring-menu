class Button
  @FAILURE-RATE = 0.3
  @buttons = []

  @disable-all-other-buttons = (this-button)-> [button.disable! for button in @buttons when button isnt this-button and button.state isnt 'done']

  @enable-all-other-buttons = (this-button)-> [button.enable! for button in @buttons when button isnt this-button and button.state isnt 'done']

  @all-button-is-done = ->
    [return false for button in @buttons when button.state isnt 'done']
    true
  
  (@dom, @good-message, @bad-message, @number-fetched-callback)->
    @state = 'enabled' ; @dom.add-class 'enabled'
    @name = @dom.find '.title' .text!
    @dom.click !~> if @state is 'enabled'
      @@@disable-all-other-buttons @
      @wait!
      @fetch-number-and-show!
    @@@buttons.push @

  fetch-number-and-show: !-> $.get '/api/random', (number, result)!~>
    @done!
    @@@all-number-fetched-callback! if @@@all-button-is-done!
    @@@enable-all-other-buttons @
    @show-number number
    @success-or-fail number

  show-number: (number)!-> @dom.find '.unread' .text number

  success-or-fail: (number)!-> 
    if is-success = Math.random! > @@@FAILURE-RATE
      @show-message @good-message
      @number-fetched-callback error = null, number
    else
      @number-fetched-callback message: @bad-message, data: number 

  show-message: !-> console.log "Button #{@name} say: #{@good-message}"

  disable: !-> @state = 'disabled' ; @dom.remove-class 'enabled' .add-class 'disabled'

  enable: !-> @state = 'enabled' ; @dom.remove-class 'disabled' .add-class 'enabled'

  wait: !-> @state = 'waiting' ; @dom.remove-class 'enabled' .add-class 'waiting'

  done: !-> @state = 'done' ; @dom.remove-class 'waiting' .add-class 'done'


cumulator =
  sum: 0
  add: (number)-> @sum += parse-int number

$ ->
  add-clicking-to-fetch-numbers-to-all-buttons!
  add-clicking-to-calculate-result-to-the-bubble!
  # add-resetting-when-leave-apb!

  s1-wait-user-clicking!

add-clicking-to-fetch-numbers-to-all-buttons = -> 
  good-messages = ['这是个天大的秘密', '我不知道', '你不知道', '他不知道', '才怪']
  bad-messages = ['这不是个天大的秘密', '我知道', '你知道', '他知道', '才怪']
  for let dom, i in $ '#control-ring .button'
    button = new Button ($ dom), good-messages[i], bad-messages[i], (error, number)!->
      if error
        console.log "Handle error from #{button.name}, message is: #{error.message}"
        number = error.data
      cumulator.add number


add-clicking-to-calculate-result-to-the-bubble = ->
  bubble = $ '#info-bar' 
  bubble.add-class 'disabled'
  Button.all-number-fetched-callback = !-> bubble.remove-class 'disabled' .add-class 'enabled'
  bubble.click !-> if bubble.has-class 'enabled'
    bubble.find '.amount' .text cumulator.sum

s1-wait-user-clicking = !-> console.log "wait user clicking ..."


