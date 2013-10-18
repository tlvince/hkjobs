exports.index = (req, res) ->
  res.render 'index',
    rss: req.app.get('rss')
    metadata:
      title: req.app.get('title')
      author: req.app.get('author')
      description: req.app.get('description')
      version: req.app.get('version')
