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

  def test_parse_starting_param_string
    expected_hash = { mode: 'cpu',
                      size: '3x3'}
    param_string  = 'mode=cpu&size=3x3'
    param_hash    = @server.parse_starting_param_string(param_string)

    assert_equal(expected_hash, param_hash)
  end

  def test_parse_move_param_string
    expected_hash = { grid_position: 'a1'}
    param_string  = 'grid_position=a1'
    param_hash    = @server.parse_move_param_string(param_string)

    assert_equal(expected_hash, param_hash)
  end

  def test_parse_starting_post
    expected_string = 'mode=cpu&size=3x3'
    post_data = 'POST /start.html HTTP/1.1
                 Host: localhost:2000
                 Connection: keep-alive
                 Content-Length: 17
                 Cache-Control: max-age=0
                 Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
                 Origin: http://localhost:2000
                 User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36
                 Content-Type: application/x-www-form-urlencoded
                 Referer: http://localhost:2000/index.html
                 Accept-Encoding: gzip, deflate
                 Accept-Language: en-US,en;q=0.8

                 mode=cpu&size=3x3'
    param_string = @server.parse_starting_post(post_data)

    assert_equal(expected_string, param_string)
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