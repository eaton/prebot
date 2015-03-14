# Description:
#   Change you can believe in!
http = require('http')

module.exports = (robot) ->
  robot.respond /petition/i, (msg) ->
    http.get('http://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=100000', (resp) ->
      body = ''
      resp.on('data', (d) ->
        body += d
      )
      resp.on('end', ->
        data = JSON.parse(body)
        # get a random index into the results of petitions w/ more than 100K signatures
        idx = Math.floor(Math.random() * 1000000) % data.results.length
        petition = data.results[idx]
        msg.send("Change you can believe in: *#{petition.title}* (#{petition.signatureCount} Signatures) #{petition.url}")
      )
    ).on('error', -> msg.reply('Looks like there was an error, sorry.'))
