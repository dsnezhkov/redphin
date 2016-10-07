# Put all your default configatron settings here.

# Top level time zone
configatron.current.time = Configatron::Dynamic.new {Time.now.utc.in_time_zone("Central Time (US & Canada)")}
# Top level redirect (override in environments)
configatron.web.rdr = 'http://example.com'
