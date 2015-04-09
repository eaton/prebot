# Description:
#   HN Api integration
#
# Dependencies:
#   "lodash": "^3.5.0"
#
# Commands:
#   hubot hn comment-lookup - passivey observes HN urls and will post summaries if they're comments

http = require 'https'
_ = require 'lodash'
he = require 'he'

module.exports = (robot) ->
  doHttpGet = (msg, url, cb) ->
    http.get(url, (resp) ->
      body = ''
      resp.on 'data', (d) ->
        body += d
      resp.on 'end', ->
        data = JSON.parse(body)
        cb(data)
    ).on 'error', -> msg.reply('An error occurred trying to search HN. Sorry.')
  robot.hear /http.*news.ycombinator.com.*item.*id=([0-9]*)/i, (msg) ->
    itemId = msg.match[1]
    url = "https://hacker-news.firebaseio.com/v0/item/#{itemId}.json"
    doHttpGet msg, url, (data) ->
      if data.type == 'comment'
        msg.send "HN Comment by #{data.by}\n```#{he.decode(data.text.replace(/<p>/g, '\n\n'))}```"
      else if data.type == 'story'
        msg.send "`#{data.title}` by #{data.by} (#{data.score} points)"
      else
        msg.send "some other msg type?"
