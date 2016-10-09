# require 'rbnacl/libsodium'
#
# module Parol
#
#     loop do
#         $password = STDIN.gets.chomp.to_s
#         break if $password.length == 32
#     end
#
#     class Crypt
#         @@box = RbNaCl::SimpleBox.from_secret_key(String.new($password, encoding: 'BINARY'))
#
#         def self.encrypt(app, usr, pwd, cmt)
#             {
#                 app: @@box.encrypt(app),
#                 usr: @@box.encrypt(usr),
#                 pwd: @@box.encrypt(pwd),
#                 cmt: @@box.encrypt(cmt)
#             }
#         end
#
#         def self.decrypt(app, usr, pwd, cmt)
#             begin
#                 {
#                     app: @@box.decrypt(app),
#                     usr: @@box.decrypt(usr),
#                     pwd: @@box.decrypt(pwd),
#                     cmt: @@box.decrypt(cmt)
#                 }
#             rescue
#                 abort '!!!Wrong Master Password!!!'
#             end
#         end
#     end
# end