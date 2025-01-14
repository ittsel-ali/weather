# frozen_string_literal: true

require 'connection_pool'
require 'redis'

# Initializes a connection pool for Redis with a maximum of 10 connections.
# The pool ensures thread-safe reuse of Redis connections across multiple threads or processes.
#
# ConnectionPool.new:
# - `size: 10`: The maximum number of Redis connections in the pool.
# - `timeout: 5`: The maximum time (in seconds) a thread will wait to acquire a connection
#   from the pool before raising a timeout error.
CACHE_POOL = ConnectionPool.new(size: 10, timeout: 5) do
  # Creates a new Redis client instance.
  # - `url: ENV['REDIS_URL']`: Reads the Redis server URL from the `REDIS_URL` environment variable.
  # - `redis://localhost:6379/0`: Uses the default Redis server URL if `REDIS_URL` is not set.
  Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/1')
end
