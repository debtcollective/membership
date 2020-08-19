# frozen_string_literal: true

# fix Passing 'exists?' command to redis as is; blind passthrough has been deprecated and will be removed in redis-namespace 2.0
# taken from https://github.com/tootsuite/mastodon/pull/14191/files

class Redis
  module NamespaceExtensions
    def exists?(*args, &block)
      call_with_namespace('exists?', *args, &block)
    end
  end
end

Redis::Namespace::COMMANDS['exists?'] = [:first]
Redis::Namespace.prepend(Redis::NamespaceExtensions)
