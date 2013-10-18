Q = require 'q'
request = require 'request'
FeedParser = require 'feedparser'

feeds = [
  'http://hongkong.craigslist.hk/search/sof?query=%20&format=rss'
  'http://hongkong.craigslist.hk/search/web?query=%20&format=rss'
  'http://pipes.yahoo.com/pipes/pipe.run?_id=52c42576e628da4851a9f0dd6c5aed3e&_render=rss'
  'http://boot.foundry8.com/feed/'
  'http://hongkong.geoexpat.com/jobs/rss.php?cat=148'
  'http://hongkong.geoexpat.com/jobs/rss.php?cat=147'
]

parse = (url, callback) ->
  items = []
  console.log "Queuing #{url}"
  request url, (error, res, body) ->
    if error? or res?.statusCode isnt 200
      callback "request: #{url}, Error: #{error}", null
    else
      request(url).pipe(new FeedParser())
      .on 'error', (error) ->
        callback error, null
      .on 'readable', ->
        items.push item if item = @.read()
      .on 'end', ->
        callback 'no articles', null if items.length is 0
        callback null, items

exports.aggregate = ->
  promises = []
  promises.push(Q.nfcall parse, feed) for feed in feeds
  promises
