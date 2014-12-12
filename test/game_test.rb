require 'minitest/autorun'
require 'minitest/spec'
require 'net/http'
require_relative '../lib/server'
require_relative '../lib/game'

class TestGame < MiniTest::Test

  def test_write_3x3_template
    opts = {
             size: '3x3',
             mode: 'cpu'
           }
    game = Game.new(opts)
    expected_template = File.read('./test/test_3x3_view.html')

    assert_equal(expected_template, game.write_starting_template)
  end

  def test_write_4x4_template
    opts = {
      size: '4x4',
      mode: 'cpu'
    }
    game = Game.new(opts)
    expected_template = File.read('./test/test_4x4_view.html')

    assert_equal(expected_template, game.write_starting_template)
  end

end