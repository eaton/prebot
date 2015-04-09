# Description:
#   "Drudge Siren" display
#
# Dependencies:
#
# Commands:
#   hubot siren - show the "druge report siren" gif
#   hubot drudge - show the "druge report siren" gif

siren_url = "http://popehat.com/wp-content/uploads/2012/06/drudge-siren.gif"

module.exports = (robot) ->
  robot.respond /drudge/, (msg) ->
    msg.send "#{siren_url}"
  robot.respond /siren/, (msg) ->
    msg.send "#{siren_url}"
