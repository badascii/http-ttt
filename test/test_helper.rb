require 'minitest/autorun'
require_relative 'http_test'
require_relative 'server_test'
require_relative 'game_3x3_test'
require_relative 'game_4x4_test'

# if __FILE__ == $0
#   $LOAD_PATH.unshift('test')
#   Dir.glob('./test/*_test.rb') { |file| require_relative file }
# end