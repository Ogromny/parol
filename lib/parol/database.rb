require 'rbnacl/libsodium'

module Parol

  class Database

    # init instance variable and check if password is 32 of length else return 'PASSWORD_IS_NOT_32_OF_LENGTH'
    def initialize database, password
      @database = database
      @password = password

      unless @password.length == 32
        return 'PASSWORD_IS_NOT_32_OF_LENGTH'
      end

      @binary_password = String.new @password, encoding: 'BINARY'

      @box = RbNaCl::SimpleBox.from_secret_key @binary_password
    end

    # ...
    def remove index
      index = Integer index
      data = decrypt

      if data.delete_at(index).nil?
        return 'INDEX_DOES_NOT_EXIST'
      end

      encrypt data
    rescue
      return 'INDEX_IS_PROBABLY_NOT_AN_INDEX'
    end

    def add program, login, password, notes
      data = decrypt

      if data == 'PASSWORD_IS_PROBABLY_INVALID'
        halt data
      end

      data << {
          program: program,
          login: login,
          password: password,
          notes: notes
      }

      encrypt data
    end

    def accounts &block
      unless block_given?
        return
      end

      data = decrypt

      if data == 'PASSWORD_IS_PROBABLY_INVALID'
        abort data
      end

      data.each do |h|
        yield h
      end
    end

    private
      # load and decrypt the database if an exception happen 'PASSWORD_IS_PROBABLY_INVALID' is returned
        def decrypt
          unless File.exist? @database
            create
            puts 'created'
          end

          data = File.binread @database
          Marshal.load @box.decrypt(data)
        rescue Exception => e
          abort "PASSWORD_IS_PROBABLY_INVALID: #{e.message}"
        end

      # encrypt the data and save it in the database
      def encrypt data
        File.open @database, 'wb' do |file|
          dump = Marshal.dump data
          file.write @box.encrypt dump
        end
      end

      # create an empty database
      def create
        File.open @database, 'wb' do |file|
          dump = Marshal.dump Array.new
          file.write @box.encrypt(dump)
        end
      end

  end

end