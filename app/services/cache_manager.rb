# frozen_string_literal: true

# app/services/pool_cache_manager.rb
require 'digest'
require 'json'
require 'connection_pool'

# Manages caching operations using a connection pool
# Includes methods to fetch, store, and delete cached data with customizable expiration and key prefixing.
class CacheManager
  DEFAULT_EXPIRATION = 24 * 60 * 60 # Default expiration time in seconds (24 hours)

  # Initializes the PoolCacheManager with a connection pool and configuration options
  #
  # @param cache_pool [ConnectionPool] A connection pool for the cache backend (e.g., Redis, Memcached)
  # @param key_prefix [String] A prefix for all cache keys
  # @param expiration [Integer] Default expiration time for cache entries in seconds
  def initialize(cache_pool, key_prefix: 'cache:', expiration: DEFAULT_EXPIRATION)
    @cache_pool = cache_pool
    @key_prefix = key_prefix
    @expiration = expiration
  end

  # Retrieves data from cache or fetches fresh data using the provided block
  #
  # @param key [String] The cache key (without prefix)
  # @yield Block to execute if cache miss occurs
  # @return [Object] Cached or freshly fetched data
  def fetch(key)
    full_key = build_key(key)

    @cache_pool.with do |cache|
      cached_data = cache.get(full_key)
      return JSON.parse(cached_data, symbolize_names: true) if cached_data

      fresh_data = yield
      store(full_key, fresh_data, cache)
      fresh_data
    end
  end

  # Stores data in the cache with expiration
  #
  # @param key [String] The cache key (already prefixed)
  # @param value [Object] The data to cache
  # @param cache [Object] The cache backend connection
  def store(key, value, cache)
    cache.set(key, value.to_json, ex: @expiration)
  end

  # Generates a unique cache key using SHA256
  #
  # @param input [String] The input string to hash
  # @return [String] A hashed key
  def generate_key(input)
    Digest::SHA256.hexdigest(input)
  end

  private

  # Builds the full key with prefix
  #
  # @param key [String] The original key
  # @return [String] The full key with prefix
  def build_key(key)
    "#{@key_prefix}#{key}"
  end
end
