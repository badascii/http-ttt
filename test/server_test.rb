require 'minitest/autorun'
require 'minitest/spec'
require 'net/http'
require_relative '../lib/server'

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

  def test_request_with_params
    line = 'GET /game.html?mode=cpu&size=3x3 HTTP/1.1'
    file = @server.requested_file(line)

    assert_equal(file, './public/game.html')
  end

  def test_valid_file
    index_path = './public/index.html'
    game_path  = './public/game.html'

    assert_equal(true, @server.valid_file?(index_path))
    assert_equal(true, @server.valid_file?(game_path))
  end

  def test_param_regex
    expected_hash = { mode: 'cpu',
                      size: '3x3'}
    param_path = '/game.html?mode=cpu&size=3x3'
    params     = @server.parse_params(param_path)

    assert_equal(expected_hash, params)
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

end