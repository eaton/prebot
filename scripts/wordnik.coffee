# Description:
#   Wordnik API integration
#
# Dependencies:
#   "lodash": "^3.5.0"
#   "node-jsxml": "^0.6.0"
#
# Commands:
#   hubot etym <word> - do wordnik etymology lookup for <word>
#   hubot define <word> - do worknik dictionary lookup for <word>

http = require 'http'
_ = require 'lodash'
moment = require 'moment'
jsxml = require "node-jsxml"

apiKey = process.env.PREBOT_WORDNIK_APIKEY

module.exports = (robot) ->
  robot.respond /etym (.*)/, (msg) ->
    word = encodeURIComponent(msg.match[1])
    url = "http://api.wordnik.com/v4/word.json/#{word}/etymologies?useCanonical=true&api_key=#{apiKey}"
    http.get(url, (resp) ->
      body = ''
      resp.on 'data', (d) ->
        body += d
      resp.on 'end', ->
        data = JSON.parse(body)
        xml = new jsxml.XML(data[0])
        msg.send "#{data[0].replace(/<[^>]*>/g, '', 'g').trim()}"
    ).on 'error', -> msg.reply('An error occurred search wordnik. Sorry.')
  robot.respond /define (.*)/, (msg) ->
    word = encodeURIComponent(msg.match[1])
    url = "http://api.wordnik.com/v4/word.json/#{word}/definitions?sourceDictionaries=all&useCanonical=true&api_key=#{apiKey}"
    http.get(url, (resp) ->
      body = ''
      resp.on 'data', (d) ->
        body += d
      resp.on 'end', ->
        data = JSON.parse(body)
        msg.send "#{data[0].text}"
    ).on 'error', -> msg.reply('An error occurred search wordnik. Sorry.')
