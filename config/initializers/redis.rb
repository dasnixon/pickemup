uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379/")
$redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
Soulmate.redis = $redis
api_uri = URI.parse(ENV["API_REDIS_URL"] || "redis://localhost:6379/")
$sores = Redis.new(host: api_uri.host, port: api_uri.port, password: api_uri.password)
