# Description:
#   Adapted from https://github.com/github/hubot-scripts/blob/master/src/scripts/twitter_mention.coffee
#   Continuously searches Twitter for mentions of a specified string.
#
#   Requires a Twitter consumer key and secret, which you can get by 
#   creating an application here: https://dev.twitter.com/apps
#
# Commands:
#   hubot twitter search <search_term> - Set search query
#   hubot twitter search - Show current search query
#
# Dependencies:
#   oauth
#
# Configuration:
#   HUBOT_TWITTER_CONSUMER_KEY
#   HUBOT_TWITTER_CONSUMER_SECRET
#
# Author:
#   timdorr
#   Jeff Olson <olson.jeffery@gmail.com>

oauth = require 'oauth'
_ = require 'lodash'

twitter_bearer_token = null

module.exports = (robot) ->
  key = process.env.HUBOT_TWITTER_CONSUMER_KEY
  secret = process.env.HUBOT_TWITTER_CONSUMER_SECRET

  twitterauth = new oauth.OAuth2(key, secret, "https://api.twitter.com/", null, "oauth2/token", null)

  twitterauth.getOAuthAccessToken "", {grant_type:"client_credentials"}, (e, access_token, refresh_token, results) ->
    twitter_bearer_token = access_token

  robot.respond /twitter (.*)/i, (msg) ->
    twitter_query = msg.match[1]
    twitter_search robot, msg, twitter_query

twitter_search = (robot, msg, query) ->
  robot.http("https://api.twitter.com/1.1/search/tweets.json")
    .header("Authorization", "Bearer #{twitter_bearer_token}")
    .query(q: escape(query), since_id: '')
    .get() (err, response, body) ->
      tweets = JSON.parse(body)
      if tweets.statuses? and tweets.statuses.length > 0
        for tweet in (if tweets.statuses.length > 5 then _.take(tweets.statuses.reverse(), 5) else tweets.statuses.reverse())
          msg.send "`@#{tweet.user.screen_name}`: #{tweet.text}"
