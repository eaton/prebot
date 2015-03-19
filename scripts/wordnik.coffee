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
jsxml = require "node-jsxml"

apiKey = process.env.PREBOT_WORDNIK_APIKEY
module.exports = (robot) ->
  doHttpGet = (msg, url, cb) ->
    http.get(url, (resp) ->
      body = ''
      resp.on 'data', (d) ->
        body += d
      resp.on 'end', ->
        data = JSON.parse(body)
        cb(data)
    ).on 'error', -> msg.reply('An error occurred trying to search wordnik. Sorry.')

  robot.respond /etym (.*)/, (msg) ->
    word = encodeURIComponent(msg.match[1])
    url = "http://api.wordnik.com/v4/word.json/#{word}/etymologies?useCanonical=true&api_key=#{apiKey}"
    doHttpGet msg, url, (data) ->
      xml = new jsxml.XML(data[0])
      msg.send "#{data[0].replace(/<[^>]*>/g, '', 'g').trim()}"
  robot.respond /define (.*)/, (msg) ->
    word = encodeURIComponent(msg.match[1])
    url = "http://api.wordnik.com/v4/word.json/#{word}/definitions?sourceDictionaries=all&useCanonical=true&api_key=#{apiKey}"
    doHttpGet msg, url, (data) ->
      msg.send "#{data[0].text}"
