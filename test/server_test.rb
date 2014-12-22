require 'minitest/autorun'
require 'minitest/spec'
require 'net/http'
require_relative '../lib/server'
require_relative '../lib/game'
require_relative '../test/mock_client'

class TestServer < MiniTest::Test
  def setup
    @server = Server.new(2000, 'localhost')
    @client = MockClient.new
    Server.clear_games
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

  def test_process_post
    @server.process_post('./public/start.html', @client)

    assert_equal(Server.hash_of_games.length, 1)
  end

  def test_fetch_post_data
    post_data       = @server.fetch_post_data(@client)
    expected_string = 'mode=cpu&size=3x3'

    assert_equal(expected_string, post_data)
  end

  def test_parse_starting_post_data
    expected_hash = { mode: 'cpu',
                      size: '3x3' }
    post_data     = 'mode=cpu&size=3x3'
    param_hash    = @server.parse_post_data(post_data)

    assert_equal(expected_hash, param_hash)
  end

  def test_parse_move_post_data
    expected_hash = { grid_position: 'a1' }
    post_data     = 'grid_position=a1'
    param_hash    = @server.parse_post_data(post_data)

    assert_equal(expected_hash, param_hash)
  end

  def test_200_header
    expected_header = "HTTP/1.1 200 OK\r\n" +
                      "Content-Type: application/octet-stream\r\n" +
                      "Content-Length: 10\r\n" +
                      "Connection: close\r\n"
    code   = 200
    type   = Server::DEFAULT_CONTENT_TYPE
    length = 10
    header = @server.build_header(code, type, length)

    assert_equal(expected_header, header)
  end

  def test_404_header
    expected_header = "HTTP/1.1 404 Not Found\r\n" +
                      "Content-Type: text/plain\r\n" +
                      "Content-Length: 10\r\n" +
                      "Connection: close\r\n"
    code   = 404
    type   = Server::CONTENT_TYPES['txt']
    length = 10
    header = @server.build_header(code, type, length)

    assert_equal(expected_header, header)
  end

  def test_get_content_length
    length = @server.get_content_length(@client)

    assert_equal(17, length)
  end

  def test_new_game_id
    assert_equal('1', @server.new_game_id)

    opts = { mode: 'cpu', size: '3x3', id: '1' }
    game = Game.new(opts)

    @server.store_game(game)

    assert_equal('2', @server.new_game_id)
  end

  def test_store_game
    opts = { mode: 'cpu', size: '3x3', id: '1' }
    game = Game.new(opts)

    @server.store_game(game)

    stored_game = Server.hash_of_games[game.id]

    assert_equal(stored_game, game)
  end

  def test_retrieve_game
    opts = { mode: 'cpu', size: '3x3', id: '1' }
    game = Game.new(opts)

    Server.hash_of_games[game.id] = game

    retrieved_game = @server.retrieve_game('1')

    assert_equal(retrieved_game, game)
  end

  # def test_build_existing_game
  #   Server.hash
  # def build_existing_game(path, params)
  #   game = retrieve_game(params[:id])

  #   game.round(params[:grid_position])
  #   game.write_template(path)
  #   store_game(game)
  # end
  # end

  def test_clear_games
    opts = { mode: 'cpu', size: '3x3', id: '1' }
    game = Game.new(opts)
    @server.store_game(game)

    assert_equal(Server.hash_of_games['1'], game)

    Server.clear_games

    assert_equal(Server.hash_of_games, {})
  end

  def test_serve_file
    file_size = @server.serve_file('./public/index.html', @client)

    assert_equal(17, file_size)
  end
end
