# 这个和例子 14 一样（14.verify_id_token_locally.rb）
# 区别是这个是用 Ruby SDK 里提供的方法来做，方便一点点

# 如何运行: ruby ./example/15.verify_id_token_locally_with_SDK.rb

require_relative '../lib/authing_ruby'
require 'dotenv'
Dotenv.load('.env.example') # 载入环境变量文件

id_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2MDk0ZThmMDI5OTZiZGU5OGE1NmVkMDEiLCJiaXJ0aGRhdGUiOm51bGwsImZhbWlseV9uYW1lIjpudWxsLCJnZW5kZXIiOiJVIiwiZ2l2ZW5fbmFtZSI6bnVsbCwibG9jYWxlIjpudWxsLCJtaWRkbGVfbmFtZSI6bnVsbCwibmFtZSI6bnVsbCwibmlja25hbWUiOiJOaWNrLea1i-ivleS_ruaUueeUqOaIt-i1hOaWmSIsInBpY3R1cmUiOiJodHRwczovL2ZpbGVzLmF1dGhpbmcuY28vYXV0aGluZy1jb25zb2xlL2RlZmF1bHQtdXNlci1hdmF0YXIucG5nIiwicHJlZmVycmVkX3VzZXJuYW1lIjpudWxsLCJwcm9maWxlIjpudWxsLCJ1cGRhdGVkX2F0IjoiMjAyMS0wNS0xM1QxMDoxNjowNy40MTVaIiwid2Vic2l0ZSI6bnVsbCwiem9uZWluZm8iOm51bGwsImFkZHJlc3MiOnsiY291bnRyeSI6bnVsbCwicG9zdGFsX2NvZGUiOm51bGwsInJlZ2lvbiI6bnVsbCwiZm9ybWF0dGVkIjpudWxsfSwicGhvbmVfbnVtYmVyIjpudWxsLCJwaG9uZV9udW1iZXJfdmVyaWZpZWQiOmZhbHNlLCJlbWFpbCI6bnVsbCwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJleHRlcm5hbF9pZCI6bnVsbCwidW5pb25pZCI6bnVsbCwiZGF0YSI6eyJ0eXBlIjoidXNlciIsInVzZXJQb29sSWQiOiI2MDgwMGI4ZWU1YjY2YjIzMTI4YjQ5ODAiLCJhcHBJZCI6IjYwODAwYjkxNTFkMDQwYWY5MDE2ZDYwYiIsImlkIjoiNjA5NGU4ZjAyOTk2YmRlOThhNTZlZDAxIiwidXNlcklkIjoiNjA5NGU4ZjAyOTk2YmRlOThhNTZlZDAxIiwiX2lkIjoiNjA5NGU4ZjAyOTk2YmRlOThhNTZlZDAxIiwicGhvbmUiOm51bGwsImVtYWlsIjpudWxsLCJ1c2VybmFtZSI6InVzZXI5NTI3IiwidW5pb25pZCI6bnVsbCwib3BlbmlkIjpudWxsLCJjbGllbnRJZCI6IjYwODAwYjhlZTViNjZiMjMxMjhiNDk4MCJ9LCJ1c2VycG9vbF9pZCI6IjYwODAwYjhlZTViNjZiMjMxMjhiNDk4MCIsImF1ZCI6IjYwODAwYjkxNTFkMDQwYWY5MDE2ZDYwYiIsImV4cCI6MTYyMjExMTYxNCwiaWF0IjoxNjIwOTAyMDE0LCJpc3MiOiJodHRwczovL3JhaWxzLWRlbW8uYXV0aGluZy5jbi9vaWRjIn0.SOXEaaQjcUoC6VEiWLWhO-X4lfhYyoKr0dDWe99qBZo"
appSecret = ENV["appSecret"]

boolean = AuthingRuby::Utils.verifyIDTokenHS256(id_token, appSecret)
if boolean
	puts "id_token 有效"
else
	puts "id_token 无效"
end
