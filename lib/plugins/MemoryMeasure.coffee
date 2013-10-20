# -- coffee --

exports.name = 'memoryMeasure'

exports.attach = (options) ->
  return done new Error('statsd required for memoryMeasure') unless @statsd?

  @memoryMeasure = setInterval () =>
    mem = process.memoryUsage()
    @statsd.gauge 'matcher.process.memoryUsage.rss', mem.rss
    @statsd.gauge 'matcher.process.memoryUsage.heapTotal', mem.heapTotal
    @statsd.gauge 'matcher.process.memoryUsage.heapUsed', mem.heapUsed
    @statsd.gauge 'matcher.process.uptime', process.uptime()
  , 10000         # every 10 seconds (like statsd is configured)
  @log.info "memoryMeasure attached"

exports.detach = ->
  clearInterval @memoryMeasure
  # clear all values
  @statsd.gauge 'matcher.process.memoryUsage.rss', 0
  @statsd.gauge 'matcher.process.memoryUsage.heapTotal', 0
  @statsd.gauge 'matcher.process.memoryUsage.heapUsed', 0
  @statsd.gauge 'matcher.process.uptime', 0

exports.init = (done) ->
  done()
