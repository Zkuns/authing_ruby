# GraphqlClient 负责发 GraphQL 请求 (其实就是 HTTP POST)
# 必须要这个是因为发请求要带上 'x-authing-userpool-id' 和 'x-authing-app-id 等 Header
# 模仿的是: 
# https://github.com/Authing/authing.js/blob/cf4757d09de3b44c3c3f4509ae8c8715c9f302a2/src/lib/common/GraphqlClient.ts#L6

require "http"
require_relative '../version.rb'

module AuthingRuby
  module Common
    class GraphqlClient
      def initialize(endpoint, options = {})
        @endpoint = endpoint # API 端点
        @options = options
      end

      def request(options)
        headers = {
          'content-type': 'application/json',
          'x-authing-sdk-version': "ruby:#{AuthingRuby::VERSION}",
          'x-authing-userpool-id': @options.fetch(:userPoolId, ''),
          'x-authing-request-from': @options.fetch(:requestFrom, 'sdk'),
          'x-authing-app-id': @options.fetch(:appId, ''),
          'x-authing-lang': @options.fetch(:lang, ''),
        };
        token = options.fetch(:token, nil)
        if token
          headers['Authorization'] = "Bearer #{token}"
        end

        json = options.fetch(:json, nil)
        # puts "@endpoint 是 #{@endpoint}"
        response = HTTP.headers(headers).post(@endpoint, json: json)
        return response.body.to_s
      end

    end
  end
end