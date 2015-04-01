class Button
  @FAILURE-RATE = 0.3
  @buttons = []

  @disable-all-other-buttons = (this-button)-> [button.disable! for button in @buttons when button isnt this-button and button.state isnt 'done']

  @enable-all-other-buttons = (this-button)-> [button.enable! for button in @buttons when button isnt this-button and button.state isnt 'done']

  @all-button-is-done = ->
    [return false for button in @buttons when button.state isnt 'done']
    true
  @reset-all = !-> [button.reset! for button in @buttons]

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

  reset: !-> 
    @state = 'enabled' ; @dom.remove-class 'disabled waiting done' .add-class 'enabled'
    @dom.find '.unread' .text ''

cumulator =
  sum: 0
  add: (number)-> @sum += parse-int number
  reset: !-> @sum = 0

$ ->
  robot.initial!
  add-clicking-to-fetch-numbers-to-all-buttons !-> robot.click-next!
  add-clicking-to-calculate-result-to-the-bubble!
  add-resetting-when-leave-apb!

  s1-wait-user-clicking!
  # s2-robot-click-buttons-from-a-to-e-then-click-bubble!
  s4-robot-generate-a-random-order-and-then-click!

add-clicking-to-fetch-numbers-to-all-buttons = (next)-> 
  good-messages = ['这是个天大的秘密', '我不知道', '你不知道', '他不知道', '才怪']
  bad-messages = ['这不是个天大的秘密', '我知道', '你知道', '他知道', '才怪']
  for let dom, i in $ '#control-ring .button'
    button = new Button ($ dom), good-messages[i], bad-messages[i], (error, number)!->
      if error
        console.log "Handle error from #{button.name}, message is: #{error.message}"
        number = error.data
      cumulator.add number
      next?!


add-clicking-to-calculate-result-to-the-bubble = ->
  bubble = $ '#info-bar' 
  bubble.add-class 'disabled'
  Button.all-number-fetched-callback = !-> bubble.remove-class 'disabled' .add-class 'enabled'
  bubble.click !-> if bubble.has-class 'enabled'
    bubble.find '.amount' .text cumulator.sum

add-resetting-when-leave-apb = !->
  is-enter-other = false
  $ '#info-bar, #control-ring' .on 'mouseenter' !-> is-enter-other := true
  $ '#info-bar, #control-ring' .on 'mouseleave' (event)!-> 
    # console.log "is leaving: ", event.target
    is-enter-other := false
    set-timeout !-> 
      reset! if not is-enter-other
    , 0

reset = !->
  cumulator.reset!
  Button.reset-all!
  bubble = $ '#info-bar'
  bubble.remove-class 'enabled' .add-class 'disabled'
  bubble.find '.amount span' .text ''


s1-wait-user-clicking = !-> console.log "wait user clicking ..."

robot =
  initial: !->
    @buttons = $ '#control-ring .button'
    @bubble = $ '#info-bar'
    @sequence = ['A' to 'E']
    @cursor = 0

  shuffle-order: !-> @sequence.sort -> 0.5 - Math.random!

  click-next: !-> if @cursor is @sequence.length then @bubble.click! else @get-next-button!click!

  get-next-button: -> 
    index = @sequence[@cursor++].char-code-at! - 'A'.char-code-at!
    @buttons[index]

  show-order: !-> @bubble.find '.sequence span' .text @sequence.join ', '

s2-robot-click-buttons-from-a-to-e-then-click-bubble = !-> $ '#button .apb' .click !-> robot.click-next!

s4-robot-generate-a-random-order-and-then-click = !-> $ '#button .apb' .click !->
  robot.shuffle-order!
  robot.show-order!
  robot.click-next!


