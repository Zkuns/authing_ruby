# 有些方法必须用"短信验证码"或"邮件验证码"
# 比如
#    通过短信验证码重置密码
#    通过邮件验证码重置密码
#    发送邮件
#    发送短信验证码
#    使用手机号验证码登录

# 我们将这些测试统一放到这个文件里，方便查找
# 因为这些方法需要手工测试，无法自动化
# ruby ./lib/test/mini_test/TestSMSandEmail.rb

require "minitest/autorun"
require "./lib/authing_ruby.rb"
require "./lib/test/helper.rb"
require 'dotenv'
Dotenv.load('.env.test') 

class TestSMSandEmail < Minitest::Test
	def setup
    # 新建一个用户侧的
    authenticationClient_options = {
      appHost: ENV["appHost"], # "https://rails-demo.authing.cn", 
      appId: ENV["appId"], # "60800b9151d040af9016d60b"
    }
    @authenticationClient = AuthingRuby::AuthenticationClient.new(authenticationClient_options)

    # 新建一个管理侧的
    managementClient_options = {
      host: 'https://core.authing.cn',
      userPoolId: ENV["userPoolId"],
      secret: ENV["secret"],
    }
    @managementClient = AuthingRuby::ManagementClient.new(managementClient_options)

    @helper = Test::Helper.new

    @phone = '13556136684' # 测发短信时需要改一下这里, 填你自己的手机号，这样才能收到短信
  end

  # 手动发送短信
  def manual_send_SMS(phone)
    sms_result = @authenticationClient.sendSmsCode(phone)
    return sms_result
    # {"code":200,"message":"发送成功"}
    #【Authing】验证码7326，该验证码5分钟内有效，请勿泄漏于他人。
  end

  # 通过短信验证码重置密码
  # ruby ./lib/test/mini_test/TestSMSandEmail.rb -n test_resetPasswordByPhoneCode
  def test_resetPasswordByPhoneCode
    # 前提条件：先确保有一个用户是自己的手机号，可以直接进 Authing 手工新建一个用户。

    phone = @phone # 手机号
    phoneCode = nil # 先保持为 nil 运行一次, 触发 manual_send_SMS 发个短信，然后自己填一下 phoneCode 为手机短信收到的验证码
    if phoneCode == nil
      # manual_send_SMS(phone) # 取消这行的注释
    else
      newPassword = '123456789'
      res = @authenticationClient.resetPasswordByPhoneCode(phone, phoneCode, newPassword)
      assert(res.dig("code") == 200, res)
    end
    # 如果成功
    # {"message":"重置密码成功！","code":200}

    # 错误可能1
    # {"errors":[{"message":{"code":2004,"message":"用户不存在"},"locations":[{"line":2,"column":5}],"path":["resetPassword"],"extensions":{"code":"INTERNAL_SERVER_ERROR"}}],"data":{"resetPassword":null}}

    # 错误可能2
    # {"errors":[{"message":{"code":2001,"message":"验证码不正确！"},"locations":[{"line":2,"column":5}],"path":["resetPassword"],"extensions":{"code":"INTERNAL_SERVER_ERROR"}}],"data":{"resetPassword":null}}
  end

  # 测试: 绑定手机号
  # ruby ./lib/test/mini_test/TestSMSandEmail.rb -n test_bindPhone
  def test_bindPhone
    # 第一步：用户名注册用户
    username = "test_bindPhone_#{@helper.randomString()}"
    password = "123456789"
    user = @authenticationClient.registerByUsername(username, password)

    # 第二步：登录用户
    @authenticationClient.loginByUsername(username, password)

    # 第三步
    phoneCode = nil # 先保持为 nil 运行一次, 触发 manual_send_SMS 发个短信，然后自己填一下 phoneCode 为手机短信收到的验证码
    if phoneCode == nil
      # manual_send_SMS(@phone) # 取消这行的注释
    else
      res = @authenticationClient.bindPhone(@phone, phoneCode)
      assert(res.dig('id') != nil)

      # 错误情况
      # puts res
      # {"errors":[{"message":{"code":500,"message":"该手机号已被绑定"},"locations":[{"line":2,"column":3}],"path":["bindPhone"],"extensions":{"code":"INTERNAL_SERVER_ERROR"}}],"data":null}
    end

    # 清理工作：测完了删除第一步注册的用户
    user_id = user['id']
    @managementClient.users.delete(user_id)
  end

  # 测试: 更新用户手机号
  def test_updatePhone
    # 前提条件：先确保有一个用户是自己的手机号，可以直接进 Authing 手工新建一个用户。
    # 填写对应手机号, 以及密码
    username = '15111111111'
    password = '123456789'
    # 登录
    user = @authenticationClient.loginByUsername(username, password)
    # 填写另一个测试号码
    phone = '15311111111'
    # 发送验证码
    manual_send_SMS(phone)
    # 填写发送的验证码
    code = '2206'

    # 默认情况下，如果用户当前已经绑定了手机号，需要同时验证原有手机号
    # 开发者也可以选择不开启 “验证原有手机号“ ，可以在 Authing 控制台 的 设置目录下的安全信息模块进行关闭。
    oldPhone = nil
    oldPhoneCode = nil

    res = @authenticationClient.updatePhone(phone, code, oldPhone, oldPhoneCode)

    # 错误情况
    #
    # {:code=>500, :message=>"该手机号已被绑定", :data=>nil}
    #
    # 错误情况
    # {:code=>2230, :message=>"新手机号和旧手机号一样", :data=>nil}

    puts res
    user_id = user['id']
    @managementClient.users.delete(user_id)
  end

end
