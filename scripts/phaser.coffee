# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->

  class EclipsePhaseRoller
    constructor: (@target) ->
      @target ?= 0
      @rolled = Math.floor(Math.random() * 100)
      @success = @rolled <= @target
      @success = true if @rolled is 0
      @success = false if @rolled is 99
      
      @critical = (@rolled % 11 == 0) || (@rolled == 0)
      if @success then @margin = @rolled else @margin = (100 - @rolled)

    @valueOf: ->
      output = ''
      if @success then output += '-'
      if @critical then output += '1'
      output += @rolled.toString()
      return parseInt(output)

    @toString: ->
      if @rolled < 10 then return ('0' + @rolled) else return @rolled

    prettyPrint: ->
      output = "#{@rolled}, targeting #{@target}. "
      if @margin > 30 then (if @success then output += 'Excellent ' else output += 'Severe ')
      if @critical then output += 'Critical '
      if @success then output += '*Success!*' else output += '*Failure!*'
      if @margin > 30 then output += " (#{@margin} #{if @success then 'MoS' else 'MoF'})"
      return output

  robot.respond /skill ([1-9]\d*)?\s*(.+)?$/i, (msg) ->
    target = msg.match[1]
    comment = msg.match[2]
    result = new EclipsePhaseRoller target
    if comment then msg.reply ("Skill check #{comment}: " + result.prettyPrint()) else msg.reply ("Skill check: " + result.prettyPrint())


  robot.respond /oppose ([1-9]\d*)\s+([1-9]\d*)\s*(.+)?$/i, (msg) ->
    att = msg.match[1]
    opp = msg.match[2]
    comment = msg.match[3]
    
    aR = new EclipsePhaseRoller att
    oR = new EclipsePhaseRoller opp
    
    if comment then msg.reply ("Opposed test #{comment}: ") else msg.reply ("Opposed test: ")
    msg.reply 'Attacker rolled ' + aR.prettyPrint()
    msg.reply 'Defender rolled ' + oR.prettyPrint()
    if aR == oR then msg.reply '*Deadlocked!*'
    if aR > oR then msg.reply '*Attacker wins!*'
    if aR < oR then msg.reply '*Defender wins!*'
