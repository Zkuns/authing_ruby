# 管理模块
require './lib/management/ManagementTokenProvider.rb'
require './lib/management/UsersManagementClient.rb'

module AuthingRuby
  class ManagementClient
    
    def initialize(options = {})
      @userPoolId = options.fetch(:userPoolId, nil)
      @secret = options.fetch(:secret, nil)
      @appId = options.fetch(:appId, nil)
      @host = options.fetch(:host, nil) # TODO
      @accessToken = options.fetch(:accessToken, nil)
      
      if @userPoolId == nil && @appId == nil
        throw '请提供 userPoolId 或者 appId!'
      end

      graphqlApiEndpointV2 = "#{@host}/graphql/v2"
      @graphqlClient = AuthingRuby::Common::GraphqlClient.new(graphqlApiEndpointV2, options)
      @tokenProvider = AuthingRuby::ManagementTokenProvider.new(options, @graphqlClient)
      @httpClient = AuthingRuby::Common::HttpClient.new(options, @tokenProvider)
      @publicKeyManager = AuthingRuby::Common::PublicKeyManager.new(options, @httpClient)

      @users = AuthingRuby::UsersManagementClient.new(
        options,
        @graphqlClient,
        @httpClient,
        @tokenProvider,
        @publicKeyManager
      );
    end

    # TODO: 先做用户相关的操作
    def users
      return @users
    end

    # def onError(code, message)
    #   throw { code, message }
    # end

    # 管理员创建账号
    # https://docs.authing.cn/v2/guides/user/create-user/
  end
end