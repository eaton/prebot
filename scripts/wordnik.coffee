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
jq = require('./util').jq
sugar = require 'sugar'

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
    word = msg.match[1]
    url = "http://www.etymonline.com/index.php?allowed_in_frame=0&search=#{word.replace(' ', '%20')}&searchmode=none"
    jq msg, url, ($) ->
      definition = $('dd:first').text().compact()
      #console.log "definition from #{url}: #{definition}"
      if definition.length > 0
        msg.send "\"#{definition.truncate(400)}\""
      else
        msg.send "No matching search results on etymonline.com for \"#{word}\""
      if definition.length > 450
        msg.send "Read more at: #{url}"

  robot.respond /define (.*)/, (msg) ->
    word = encodeURIComponent(msg.match[1])
    url = "http://api.wordnik.com/v4/word.json/#{word}/definitions?sourceDictionaries=all&useCanonical=true&api_key=#{apiKey}"
    doHttpGet msg, url, (data) ->
      msg.send "#{data[0].text}"
