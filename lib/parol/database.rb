require 'rbnacl/libsodium'

module Parol

  class ParolError < StandardError; end
  class BadPasswordLength < ParolError; end
  class DecryptionFailed < ParolError; end # wrong password or wrong file

  class Database

    def initialize database, password
      @database = database
      @password = password

      @binary_password = String.new @password, encoding: 'BINARY'
      @box = RbNaCl::SimpleBox.from_secret_key @binary_password

      rescue RbNaCl::LengthError
        raise BadPasswordLength
    end

    def add program, login, password, notes
      data = decrypt

      data << {
          program: program,
          login: login,
          password: password,
          notes: notes
      }

      encrypt data
    end

    def accounts &block
      data = decrypt

      if block_given?
        data.each do |h|
          yield h
        end
      else
        data
      end
    end

    private
    def decrypt
      unless File.exist? @database
        create
      end

      data = File.binread @database
      Marshal.load @box.decrypt(data)

    rescue RbNaCl::CryptoError
      raise DecryptionFailed
    end

    def encrypt data
      File.open @database, 'wb' do |file|
        dump = Marshal.dump data
        file.write @box.encrypt dump
      end
    end

    def create
      File.open @database, 'wb' do |file|
        dump = Marshal.dump Array.new
        file.write @box.encrypt(dump)
      end
    end

  end

end