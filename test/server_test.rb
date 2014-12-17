require 'minitest/autorun'
require 'minitest/spec'
require 'net/http'
require_relative '../lib/server'
require_relative '../lib/game'

class TestServer < MiniTest::Test

  def setup
    @server = Server.new(2000, 'localhost')
  end

  def test_initialize
    assert_equal(@server.class, Server)
  end

  def test_status_messages
    assert_equal(Server::STATUS_MESSAGES[200], 'OK')
    assert_equal(Server::STATUS_MESSAGES[404], 'Not Found')
  end

  def test_default_content_type
    default_content_type = @server.content_type('file.blah')

    assert_equal(default_content_type, 'application/octet-stream')
  end

  def test_supported_content_types
    html = @server.content_type('a.html')
    txt  = @server.content_type('b.txt')
    png  = @server.content_type('c.png')
    jpg  = @server.content_type('d.jpg')

    assert_equal(html, 'text/html')
    assert_equal(txt, 'text/plain')
    assert_equal(png, 'image/png')
    assert_equal(jpg, 'image/jpeg')
  end

  def test_requested_file
    line = 'GET /index.html HTTP/1.1'
    file = @server.requested_file(line)

    assert_equal(file, './public/index.html')
  end

  def test_valid_file
    index_path = './public/index.html'
    game_path  = './public/game.html'

    assert_equal(true, @server.valid_file?(index_path))
    assert_equal(true, @server.valid_file?(game_path))
  end

  def test_invalid_file
    invalid_path = './somewhere/some_file.html'

    assert_equal(false, @server.valid_file?(invalid_path))
  end

  def test_parse_starting_param_string
    expected_hash = { mode: 'cpu',
                      size: '3x3'}
    param_string  = 'mode=cpu&size=3x3'
    param_hash    = @server.parse_param_string(param_string)

    assert_equal(expected_hash, param_hash)
  end

  def test_parse_move_param_string
    expected_hash = { grid_position: 'a1'}
    param_string  = 'grid_position=a1'
    param_hash    = @server.parse_param_string(param_string)

    assert_equal(expected_hash, param_hash)
  end

  def test_200_header
    code   = 200
    type   = Server::DEFAULT_CONTENT_TYPE
    length = 10
    header = @server.build_header(code, type, length)

    assert_equal(header, "HTTP/1.1 200 OK\r\n" +
                         "Content-Type: application/octet-stream\r\n" +
                         "Content-Length: 10\r\n" +
                         "Connection: close\r\n")
  end

  def test_404_header
    code   = 404
    type   = Server::CONTENT_TYPES['txt']
    length = 10
    header = @server.build_header(code, type, length)

    assert_equal(header, "HTTP/1.1 404 Not Found\r\n" +
                         "Content-Type: text/plain\r\n" +
                         "Content-Length: 10\r\n" +
                         "Connection: close\r\n")
  end

  def test_new_game_id
    opts = { mode: 'cpu', size: '3x3', id: 1 }
    game = Game.new(opts)

    @server.store_game(game)

    assert_equal(2, @server.new_game_id)
  end

  def test_store_game
    opts          = { mode: 'cpu', size: '3x3', id: 1 }
    expected_game = Game.new(opts)

    @server.store_game(expected_game)

    stored_game   = Server.hash_of_games[expected_game.id]

    assert_equal(stored_game, expected_game)
  end

  def test_retrieve_game
    opts          = { mode: 'cpu', size: '3x3', id: 1 }
    expected_game = Game.new(opts)

    Server.hash_of_games[expected_game.id] = expected_game

    retrieved_game = @server.retrieve_game(1)

    assert_equal(retrieved_game, expected_game)
  end

end