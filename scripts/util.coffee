# Adapted, by Jeff Olson, from:
# https://gist.github.com/790580
#
# Scraping Made Easy with jQuery and SelectorGadget
# (http://blog.dtrejo.com/scraping-made-easy-with-jquery-and-selectorga)
# by David Trejo
#
# Install node.js and npm:
#    http://joyeur.com/2010/12/10/installing-node-and-npm/
# Then run
#    npm install jsdom jquery http-agent
#    node numresults.js
#
util = require 'util'
url = require 'url'
#httpAgent = require 'http-agent'

http = require 'http'
https = require 'https'

jsdom = require('jsdom').jsdom
_ = require 'lodash'
jquery = require 'jquery'

moz_agent = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:12.0)' +
            ' Gecko/20100101 Firefox/12.0'

httpsGet = (msg, url, cb) ->
  http.get(url, (resp) ->
    body = ''
    resp.on 'data', (d) ->
      body += d
    resp.on 'end', ->
      data = JSON.parse(body)
      cb(data)
  ).on 'error', -> msg.reply('An error occurred trying to search wordnik. Sorry.')

httpGet = (msg, url, cb) ->
  http.get(url, (resp) ->
    body = ''
    resp.on 'data', (d) ->
      body += d
    resp.on 'end', ->
      cb(body)
  ).on 'error', -> msg.reply('An error occurred trying to search wordnik. Sorry.')

scrape_jq = (msg, raw_url, cb) ->
  get = if url.parse(raw_url).protocol == 'http:' then httpGet else httpsGet
  get msg, raw_url, (body) ->
    window = jsdom(body).parentWindow
    jq = jquery(window)
    cb(jq)

module.exports =
  httpGet: httpGet,
  httpsGet: httpsGet,
  jq: scrape_jq
