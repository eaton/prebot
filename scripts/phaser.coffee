# Description
#   Simple dice notation rolls, and Eclipse Phase specific rolls like skill checks
#   and opposed tests. Calculates Margin of Failure/Success and recognizes criticals.
#
# Dependencies:
#   "droll": "^0.1.1"
#
# Commands:
#   hubot roll <notation> (comments) - 1d6-1 style dice notation.
#   hubot skill <target> (comments) - Eclipse Phase skill test for a target number
#   hubot oppose <attack> <defend> (comments) - Eclipse Phase opposed test with two target numbers
#
# Author:
#   eaton

droll = require("droll");

module.exports = (robot) ->

  class EclipsePhaseRoller
    constructor: (@target) ->
      @target ?= 0
      @rolled = Math.floor(Math.random() * 100)
      @success = @rolled <= @target
      @success = true if @rolled is 0
      @success = false if @rolled is 99
      
      @critical = @rolled % 11 == 0 or @rolled == 0
      if @success then @margin = @rolled else @margin = (@rolled - @target)

    valueOf: ->
      output = if @success then '' else '-'  # Failure always sorts lower than success
      output += '1' if @critical             # Magnitude increased for criticals
      output += @rolled.toString()           # Actual rolled value
      return +output                         # Aaaaaand return the int

    toString: ->
      return if @rolled < 10 then '0' + @rolled else @rolled

    prettyPrint: ->
      output = "#{@rolled}, targeting #{@target}. "
      if @margin > 30 then (if @success then output += 'Excellent ' else output += 'Severe ')
      if @critical then output += 'Critical '
      if @success then output += '*Success!*' else output += '*Failure!*'
      if @margin > 30 then output += " (#{@margin} #{if @success then 'MoS' else 'MoF'})"
      return output

  # Simple dice roll
  robot.respond /roll (\d*)?d?(\d*)?([+-]\d+)?\s*(.+)?$/i, (msg) ->
    formula = "#{msg.match[1] ?= 1}d#{msg.match[2] ?= 6}#{msg.match[3] ?= ''}"
    msg.send "Rolled #{formula}#{if msg.match[4] then ' ' + msg.match[4] else ''}: #{droll.roll(formula)}"

  # Eclipse Phase skill check
  robot.respond /skill ([1-9]\d*)?\s*(.+)?$/i, (msg) ->
    target = msg.match[1]
    comment = msg.match[2]
    result = new EclipsePhaseRoller target
    if comment then msg.send ("Skill check #{comment}: " + result.prettyPrint()) else msg.send ("Skill check: " + result.prettyPrint())

  # Eclipse Phase opposed check
  robot.respond /oppose ([1-9]\d*)\s+([1-9]\d*)\s*(.+)?$/i, (msg) ->
    att = new EclipsePhaseRoller msg.match[1]
    opp = new EclipsePhaseRoller msg.match[2]
    comment = msg.match[3]
    
    if comment then msg.reply "Opposed test #{comment}: " else msg.reply ("Opposed test: ")
    msg.send 'Attacker rolled ' + att.prettyPrint()
    msg.send 'Defender rolled ' + opp.prettyPrint()
    msg.send switch
      when not att.success and not opp.success then '*Deadlocked!*'
      when att == opp then '*Deadlocked!*'
      when att > opp then '*Attacker wins!*'
      when att < opp then '*Defender wins!*'
