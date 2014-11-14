# Start server locally with bin/start before running these tests

require 'minitest/autorun'
require 'minitest/spec'
require 'net/http'

class TestHTTP < MiniTest::Test

  def setup
    @uri = URI('http://localhost:2000/')
  end

  def test_uri
    assert_equal(@uri.scheme, 'http')
    assert_equal(@uri.host, 'localhost')
  end

  def test_hello_world
    response = Net::HTTP.get_response(@uri + 'index.html')
    assert(response.body.include?('Tic-Tac-Toe'))
  end

  def test_index
    response = Net::HTTP.get_response(@uri + 'index.html')
    assert_equal(response.code, '200')
    assert_equal(response.message, 'OK')
  end

 def test_root_serves_index
    response = Net::HTTP.get_response(@uri)
    assert_equal(response.code, '200')
    assert_equal(response.message, 'OK')
  end

  def test_file_outside_public
    response = Net::HTTP.get_response(@uri + 'inaccessible.html')
    assert_equal(response.code, '404')
  end

  # def test_client_requests_directory
  #   response = Net::HTTP.get_response('/../../../../etc/passwd')
  #   assert_equal(response.code, '404')
  # end
end