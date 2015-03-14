# Description:
#   Change you can believe in!
#
# Dependencies:
#   "lodash": "^3.5.0"
#   "moment": "^2.9.0"
#
# Commands:
#   hubot petition - Returns a random whitehouse.gov petition.
#   hubot top petitions - Returns the top 5 whitehouse.gov petitions

http = require('http')
_ = require('lodash')
moment = require('moment')

module.exports = (robot) ->
  popularPetitionQuery = 'http://api.whitehouse.gov/v1/petitions.json?limit=1000&signatureCountFloor=50000'
  aMonthAgo = moment().subtract(1, 'month').unix()
  recentPetitionsQuery = "http://api.whitehouse.gov/v1/petitions.json?limit=1000&createdAfter=#{aMonthAgo}"
  doPetitionQuery = (url, msg, cb) ->
    http.get(url, (resp) ->
      body = ''
      resp.on 'data', (d) ->
        body += d
      resp.on 'end', ->
        data = JSON.parse(body)
        cb(data)
    ).on('error', -> msg.reply('Looks like there was an error, sorry.'))
  petitionHandler = (msg) ->
    doPetitionQuery popularPetitionQuery, msg, (data) ->
      # get a random index into the results of petitions w/ more than 100K signatures
      idx = Math.floor(Math.random() * 1000000) % data.results.length
      petition = data.results[idx]
      msg.send("Random petition from all with 50K+ signatures (#{data.results.length} total): *#{petition.title}* (#{petition.signatureCount} Signatures) #{petition.url}")
  robot.respond /petition$/, petitionHandler
  topPetitionsHandler = (msg) ->
    doPetitionQuery recentPetitionsQuery, msg, (data) ->
      # order the data by signature count (descending) and then get the top 5
      ordered = _.take(_.sortBy(data.results, (r) -> r.signatureCount).reverse(), 5)
      memo = _.reduce(ordered, (memo, petition) ->
        "#{memo}\n*#{petition.title}* (#{petition.signatureCount} Signatures) #{petition.url}"
      , "Top 5 petitions, by signature count, in the last month:")
      msg.send(memo)
  robot.respond /top petitions/, topPetitionsHandler
