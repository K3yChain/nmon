class Dashing.Bart extends Dashing.Widget

  ready: ->
    @stationElem = $(@node).find('.station')
    @estimatesElem = $(@node).find('.estimates')
    @wrapElem = $(@node).find('.wrap')
    @updateDestination()

  onData: (data) ->
    @updateDestination()


  updateDestination: =>
    @destination = @get("destination")
    @destination.formatted_estimates = ""
    @destination.formatted_estimates += @formatEstimate estimate for estimate in @destination.estimates
    @set 'curr_dest', @destination


  formatEstimate: (est) =>
    "<div class='estimate'><div class='time'>#{est.minutes.toString().lpad("&nbsp;", 2)} min</div><div class='cars'>#{est.train_length.toString().lpad("&nbsp;", 2)} cars</div></div>"



#stding padding function
if (typeof String::lpad != 'function')
  String::lpad = (padString, length) ->
    str = this
    while str.length < length
      str = padString + str
    return str