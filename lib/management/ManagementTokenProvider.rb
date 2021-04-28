# 复刻一个 JS SDK 里的 ManagementTokenProvider （方法名字，返回值，参数的数量和顺序，都尽量保持一致）
# 这玩意的目的就是管理 accessToken

# authing.js/src/lib/management/ManagementTokenProvider.ts
# https://github.com/Authing/authing.js/blob/fad3b5ba03de36968422f23971b281dbb7de2187/src/lib/management/ManagementTokenProvider.ts#L6

require './lib/GraphQLAPI.rb'
require 'jwt'

module AuthingRuby
	class ManagementTokenProvider

		def initialize(options = {}, graphqlClient = nil)
			@options = options;
			@graphqlClient = graphqlClient;

			@_accessToken = nil
			@_accessTokenExpriredAt = nil # 过期时间
	
			accessToken = options.fetch(:accessToken, nil)
			# 如果 options 里传入了 accessToken
			if accessToken
				@_accessToken = accessToken;
				decoded_token_array = JWT.decode @_accessToken, nil, false # 试着解析一下
				payload = decoded_token_array[0]
				exp = payload.dig('exp'); # exp 是过期时间（秒）
				@_accessTokenExpriredAt = exp; # 把过期时间存起来
			end
		end

		# done
		# 得先把这个做了, users.create 才能用
		def getToken()
			accessToken = @options.fetch(:accessToken, nil)
			return accessToken if accessToken
			
			# 缓存到 accessToken 过期前 3600 s
			current_timestamps_in_second = Time.now.to_i
			if @_accessToken && @_accessTokenExpriredAt > current_timestamps_in_second + 3600
				return @_accessToken
			end

			return _getAccessTokenFromServer();
		end

		# done
		def _getAccessTokenFromServer
			accessToken = nil;
			secret = @options.fetch(:secret, nil)
			if secret
				accessToken = getClientWhenSdkInit()
			else
				accessToken = refreshToken()
			end

			@_accessToken = accessToken;
			decoded_token_array = JWT.decode @_accessToken, nil, false
			payload = decoded_token_array[0]
			# {"data"=>{"type"=>"user", "userPoolId"=>"59f86b4832eb28071bdd9214", "arn"=>"arn:cn:authing:59f86b4832eb28071bdd9214:user:607b0b15aab3a805f7ea6617", "id"=>"607b0b15aab3a805f7ea6617", "userId"=>"607b0b15aab3a805f7ea6617", "_id"=>"607b0b15aab3a805f7ea6617", "phone"=>"13556136684", "email"=>nil, "username"=>nil, "unionid"=>nil, "openid"=>nil, "clientId"=>"59f86b4832eb28071bdd9214"}, "iat"=>1619579553, "exp"=>1620875553}
			exp = payload.dig('exp'); # exp 是过期时间（秒）
			@_accessTokenExpriredAt = exp
			return @_accessToken;
		end

		# 发送 GraphQL 接口请求获取 accessToken
		def getClientWhenSdkInit
			variables = {
				userPoolId: @options.fetch(:userPoolId, nil),
				secret: @options.fetch(:secret, nil),
			}
      api = AuthingRuby::GraphQLAPI.new
			res = api.getAccessToken(@graphqlClient, variables)
			# {"data":{"accessToken":{"accessToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7InR5cGUiOiJ1[省略]ZWE2NjE3IiwidXNlcks2lkIjoiNjA3YjBiMTVhYWIzYTgwNWY3ZWE2NjE3IiwiX2lkIjoiNjA3YjBiMTVhYWIzYTgwNWY3ZWE2NjE3IiwicGhvbmz3Mzk5M30.K7pwyvbxypeiOlYRsTIlLXY2xyk94tTd-CATQ85jYqM","exp":1620873993,"iat":1619577993}}}
			hash = JSON.parse(res)
			return hash.dig("data", "accessToken", "accessToken")
		end

		# TODO
		def refreshToken
			api = AuthingRuby::GraphQLAPI.new
			res = api.refreshAccessToken(@graphqlClient, {
				accessToken: @options.fetch(:accessToken, nil)
			})
			hash = JSON.parse(res)
			# puts hash
			# {"errors"=>[{"message"=>{"code"=>500, "message"=>"该 token 在黑名单中"}, "locations"=>[{"line"=>2, "column"=>5}], "path"=>["refreshAccessToken"], "extensions"=>{"code"=>"INTERNAL_SERVER_ERROR", "exception"=>{"name"=>"TokenInBlackListError"}}}], "data"=>nil}
			if hash.dig("errors")
				return hash
			end
			return hash.dig("data", "refreshAccessToken", "accessToken")
		end
	end
end