module AuthingRuby
	class AuthenticationClient
		def initialize(options = {})
			@options = options

			# 应用 ID
			@appId = options.fetch(:appId, nil) 
			# https://docs.authing.cn/v2/guides/faqs/get-app-id-and-secret.html
			# 如何获取应用 ID (AppID) 和应用密钥（AppSecret）
			# appHost 是 该应用的域名（AppHost），如 https://my-awesome-app.authing.cn
			# appHost 的获取方法：某用户池 -> 应用 -> 基础设置 -> 认证地址
			if @appId == nil
				# 提示 appId 是个必须的参数
			end

			@secret = options.fetch(:secret, nil) # 应用密钥
			@appHost = options.fetch(:appHost, nil) # 该应用的域名
			@redirectUri = options.fetch(:redirectUri, nil) # 业务回调地址
			@authing_graphql_endpoint = 'https://core.authing.cn/graphql'

			# 公钥加密
			@publicKeyManager = Common::PublicKeyManager.new(options)

			# 负责发送 GraphQL (其实就是 http) 请求的工具
			graphqlEndpoint = "#{@appHost}/graphql/v2";
			@graphqlClient = Common::GraphqlClient.new(graphqlEndpoint, @options)
			
			# tokenProvider 只是存取一下 user 和 token
			@tokenProvider = Authentication::AuthenticationTokenProvider.new()

			# @httpClient = HttpClient

			# 把 GraphQL 文件夹路径放这里, 这些是私有变量
			@folder_graphql = "./lib/graphql"
			@folder_graphql_mutation = "#{@folder_graphql}/mutations"
			@folder_graphql_query = "#{@folder_graphql}/queries"
		end

		# 使用邮箱+密码注册 (完成, 测试通过)
		# 参照: https://docs.authing.cn/v2/reference/sdk-for-node/authentication/AuthenticationClient.html
		# 测试代码: 
		# a = AuthingRuby::AuthenticationClient.new({appHost: "https://rails-demo.authing.cn", appId: "60800b9151d040af9016d60b"})
		# a.registerByEmail('301@qq.com', "123456789")
		def registerByEmail(email, password, profile = {}, options = {})
			# 第一步：构建 variables
			publicKey = @publicKeyManager.getPublicKey()
			encryptedPassword = Utils.encrypt(password, publicKey)
			variables = {
				"input": {
					"email": email,
					"password": encryptedPassword,

					"profile": profile,
					"forceLogin": options.fetch(:forceLogin, false),
					"clientIp": options.fetch(:clientIp, nil),
					"context": options.fetch(:context, nil),
					"generateToken": options.fetch(:generateToken, nil),
				}
			}
			# 第二步：构建 payload
			file = File.open("#{@folder_graphql_mutation}/registerByEmail.gql")
			json = {
				"query": file.read,
				"variables": variables,
			}
			# 第三步：发请求
			response = @graphqlClient.request({json: json})
			return response
		end

		# 使用用户名注册
		# https://docs.authing.cn/v2/reference/sdk-for-node/authentication/AuthenticationClient.html#%E4%BD%BF%E7%94%A8%E7%94%A8%E6%88%B7%E5%90%8D%E6%B3%A8%E5%86%8C
		# a = AuthingRuby::AuthenticationClient.new({appHost: "https://rails-demo.authing.cn", appId: "60800b9151d040af9016d60b"})
		# a.registerByUsername('agoodob', "123456789")
		def registerByUsername(username, password, profile = {}, options = {})
			# 第一步：构建 variables
			publicKey = @publicKeyManager.getPublicKey()
			encryptedPassword = Utils.encrypt(password, publicKey)
			variables = {
				"input": {
					"username": username,
					"password": encryptedPassword,

					"profile": profile,
					"forceLogin": options.fetch(:forceLogin, false),
					"clientIp": options.fetch(:clientIp, nil),
					"context": options.fetch(:context, nil),
					"generateToken": options.fetch(:generateToken, nil),
				}
			}
			# 第二步：构建 payload
			file = File.open("#{@folder_graphql_mutation}/registerByUsername.gql")
			json = {
				"query": file.read,
				"variables": variables,
			}
			# 第三步：发请求
			response = @graphqlClient.request({json: json})
			return response
		end

		# 发送短信验证码
		# a = AuthingRuby::AuthenticationClient.new({appHost: "https://rails-demo.authing.cn", appId: "60800b9151d040af9016d60b", userPoolId: "60800b8ee5b66b23128b4980"})
		# a.sendSmsCode("13556136684")
		def sendSmsCode(phone)
			url = "#{@appHost}/api/v2/sms/send"
			graphqlClient = Common::GraphqlClient.new(url, @options)
			json = {
				"phone": phone
			}
			response = graphqlClient.request({json: json})
			#  "{\"code\":200,\"message\":\"发送成功\"}"
			return response
		end

		# 使用手机号注册
		# a = AuthingRuby::AuthenticationClient.new({appHost: "https://rails-demo.authing.cn", appId: "60800b9151d040af9016d60b", userPoolId: "60800b8ee5b66b23128b4980"})
		# a.registerByPhoneCode("13556136684", "6330", "123456")
		def registerByPhoneCode(phone, code, password, profile = {}, options = {})
			# 第一步：构建 variables
			publicKey = @publicKeyManager.getPublicKey()
			encryptedPassword = Utils.encrypt(password, publicKey)
			variables = {
				"input": {
					"phone": phone,
					"code": code,
					"password": encryptedPassword,

					"profile": profile,
					"forceLogin": options.fetch(:forceLogin, false),
					"clientIp": options.fetch(:clientIp, nil),
					"context": options.fetch(:context, nil),
					"generateToken": options.fetch(:generateToken, nil),
				}
			}
			# 第二步：构建整个 payload
			file = File.open("#{@folder_graphql_mutation}/registerByPhoneCode.gql")
			json = {
				"query": file.read,
				"variables": variables,
			}
			# 第三步：发请求
			response = @graphqlClient.request({json: json})
			return response
		end

		# 使用邮箱登录
		# a = AuthingRuby::AuthenticationClient.new({appHost: "https://rails-demo.authing.cn", appId: "60800b9151d040af9016d60b", userPoolId: "60800b8ee5b66b23128b4980"})
		# a.loginByEmail('301@qq.com', "123456789")
		def loginByEmail(email, password, options = {})
			# 第一步：构建 variables
			publicKey = @publicKeyManager.getPublicKey()
			encryptedPassword = Utils.encrypt(password, publicKey)
			variables = {
				"input": {
					"email": email,
					"password": encryptedPassword,

					"autoRegister": options.fetch(:autoRegister, nil),
					"captchaCode": options.fetch(:captchaCode, nil),
					"clientIp": options.fetch(:clientIp, nil),
				}
			}
			# 第二步：构建整个 payload
			file = File.open("#{@folder_graphql_mutation}/loginByEmail.gql")
			json = {
				"query": file.read,
				"variables": variables,
			}
			# 第三步：发请求
			response = @graphqlClient.request({json: json})

			# 第四步：把结果存起来
			json = JSON.parse(response)
			user = json['data']['loginByEmail']
			setCurrentUser(user);

			return response
		end

		# 使用用户名登录
		# a = AuthingRuby::AuthenticationClient.new({appHost: "https://rails-demo.authing.cn", appId: "60800b9151d040af9016d60b"})
		# a.loginByUsername('agoodob', "123456789")
		def loginByUsername(username, password, options = {})
			# 第一步：构建 variables
			publicKey = @publicKeyManager.getPublicKey()
			encryptedPassword = Utils.encrypt(password, publicKey)
			variables = {
				"input": {
					"username": username,
					"password": encryptedPassword,

					"autoRegister": options.fetch(:autoRegister, nil),
					"captchaCode": options.fetch(:captchaCode, nil),
					"clientIp": options.fetch(:clientIp, nil),
				}
			}
			# 第二步：构建整个 payload
			file = File.open("#{@folder_graphql_mutation}/loginByUsername.gql")
			json = {
				"query": file.read,
				"variables": variables,
			}
			# 第三步：发请求
			response = @graphqlClient.request({json: json})

			# 第四步：把结果存起来
			json = JSON.parse(response)
			user = json['data']['loginByUsername']
			setCurrentUser(user);

			return response
		end

		# 使用手机号验证码登录
		# a = AuthingRuby::AuthenticationClient.new({appHost: "https://rails-demo.authing.cn", appId: "60800b9151d040af9016d60b"})
		# a.sendSmsCode("13556136684")
		# a.loginByPhoneCode("13556136684", "1347")
		def loginByPhoneCode(phone, code, options = {})
			# 第一步：构建 variables
			variables = {
				"input": {
					"phone": phone,
					"code": code,
					"clientIp": options.fetch(:clientIp, nil),
				}
			}
			# 第二步：构建 payload
			file = File.open("#{@folder_graphql_mutation}/loginByPhoneCode.gql")
			json = {
				"query": file.read,
				"variables": variables,
			}
			# 第三步：发请求
			response = @graphqlClient.request({json: json})

			# 第四步：把结果存起来
			json = JSON.parse(response)
			user = json['data']['loginByPhoneCode']
			setCurrentUser(user);

			return response
		end

		# 使用手机号密码登录
		# a = AuthingRuby::AuthenticationClient.new({appHost: "https://rails-demo.authing.cn", appId: "60800b9151d040af9016d60b"})
		# a.loginByPhonePassword("13556136684", "123456")
		def loginByPhonePassword(phone, password, options = {})
			# 第一步：构建 variables
			publicKey = @publicKeyManager.getPublicKey()
			encryptedPassword = Utils.encrypt(password, publicKey)
			variables = {
				"input": {
					"phone": phone,
					"password": encryptedPassword,

					"captchaCode": options.fetch(:captchaCode, nil),
					"clientIp": options.fetch(:clientIp, nil),
				}
			}
			# 第二步：构建 payload
			file = File.open("#{@folder_graphql_mutation}/loginByPhonePassword.gql")
			json = {
				"query": file.read,
				"variables": variables,
			}
			# 第三步：发请求
			response = @graphqlClient.request({json: json})

			# 第四步：把结果存起来
			json = JSON.parse(response)
			user = json['data']['loginByPhonePassword']
			setCurrentUser(user);

			return response
		end

		def checkLoginStatus
		end

		# 发送邮件
		# 待测试
		# a = AuthingRuby::AuthenticationClient.new({appHost: "https://rails-demo.authing.cn", appId: "60800b9151d040af9016d60b"})
		# a.sendEmail('guokrfans@gmail.com', "VERIFY_EMAIL")
		# * @param {EmailScene} scene 发送场景，可选值为 RESET_PASSWORD（发送重置密码邮件，邮件中包含验证码）、VerifyEmail（发送验证邮箱的邮件）、ChangeEmail（发送修改邮箱邮件，邮件中包含验证码）
		def sendEmail(email, scene)
			# 第一步：构建 variables
			variables = {
				"email": email,
				"scene": scene,
			}
			# 第二步：构建 payload
			file = File.open("#{@folder_graphql_mutation}/sendEmail.gql")
			json = {
				"query": file.read,
				"variables": variables,
			}
			# 第三步：发请求
			response = @graphqlClient.request({json: json})
			return response
			# "{\"data\":{\"sendEmail\":{\"message\":\"\",\"code\":200}}}\n"
		end

		# 获取当前登录的用户信息
		# a = AuthingRuby::AuthenticationClient.new({appHost: "https://rails-demo.authing.cn", appId: "60800b9151d040af9016d60b"})
		# a.loginByUsername('agoodob', "123456789")
		# a.getCurrentUser()
		def getCurrentUser()
			file = File.open("#{@folder_graphql_query}/user.gql")
			json = {
				"query": file.read
			}
			token = @tokenProvider.getToken();
			# 第三步：发请求
			response = @graphqlClient.request({json: json, token: token})
			json = JSON.parse(response)
			setCurrentUser(json['data']['user'])
			return response
		end

		def setCurrentUser(user)
			@tokenProvider.setUser(user);
		end

		def setToken(token)
			@tokenProvider.setToken(token);
		end

		# a.testGetUser()
		# def testGetUser()
		#   @tokenProvider.getUser();
		# end

		# 退出登录
		# TODO
		def logout()
			# await this.httpClient.request({
			#   method: 'GET',
			#   url: ,
			#   withCredentials: true
			# });
			# resp = HTTP.get("#{@appHost}/api/v2/logout?app_id=#{@appId}")
			@tokenProvider.clearUser();
		end
	end
end