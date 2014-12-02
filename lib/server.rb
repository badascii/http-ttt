require 'socket'
require 'uri'
require 'gserver'
require 'erb'
require 'cgi'
require 'cgi/session'
require_relative 'game'

class Server < GServer

  ROOT = './public'

  CONTENT_TYPES = {'html' => 'text/html',
                   'txt'  => 'text/plain',
                   'png'  => 'image/png',
                   'jpg'  => 'image/jpeg'}

  DEFAULT_CONTENT_TYPE = 'application/octet-stream'

  STATUS_MESSAGES = {200 => 'OK',
                     404 => 'Not Found'}

  def initialize(port=2000, *args)
    super(port, *args)
  end

  def serve(client)
    loop do
      # cgi     = CGI.new
      # session = CGI::Session.new(cgi)
      # id      = session.session_id

      line   = client.readline
      path   = requested_file(line)
      path   = File.join(path, 'index.html') if File.directory?(path)

      if line.include?('POST')
        post_data    = client.read(517)
        param_string = parse_post(post_data)
        # game   = Game.new(param_hash)
        # game.write_template
      end

      if line.include?('?')
        params = build_param_hash(line)
        game   = Game.new(params)
        game.write_template
      end

      puts "Got request for: #{path}"
      send_response(path, client)
    end
  end

  def content_type(path)
    ext = File.extname(path).split('.').last
    CONTENT_TYPES.fetch(ext, DEFAULT_CONTENT_TYPE)
  end

  def requested_file(line)
    request_uri  = line.split(' ')[1]
    path         = URI.unescape(URI(request_uri).path)

    File.join(ROOT, path)
  end

  def send_response(path, client)
    if valid_file?(path)
      serve_file(path, client)
    else
      file_not_found(client)
    end
  end

  def valid_file?(path)
    File.exist?(path) && !File.directory?(path)
  end

  def serve_file(path, client)
    File.open(path, 'rb') do |file|
      header = build_header(200, content_type(file), file.size)
      client.print(header)
      client.print("\r\n")

      IO.copy_stream(file, client)
    end
  end

  def file_not_found(client)
    message = "File not found\n"

    header = build_header(404, 'text/plain', message.size)

    client.print(header)
    client.print("\r\n")
    client.print(message)
  end

  def build_header(code, type, length)
    "HTTP/1.1 #{code} #{STATUS_MESSAGES[code]}\r\n" +
    "Content-Type: #{type}\r\n" +
    "Content-Length: #{length}\r\n" +
    "Connection: close\r\n"
  end

  def build_param_hash(line)
    request_uri     = line.split(' ')[1]
    array_of_params = uri_params(request_uri)
    param_hash      = {}

    array_of_params.each do |param|
      key   = param.split('=')[0]
      value = param.split('=')[1]
      param_hash[key.to_sym] = value
    end
    return param_hash
  end

  def parse_post(post_data)
    post_data.split(//).last(18).join
  end

  def parse_param_string(param_string)
    param_hash = {}
    array_of_params = param_string.split('&')

    array_of_params.each do |param|
      key   = param.split('=')[0]
      value = param.split('=')[1]
      param_hash[key.to_sym] = value
    end

    return param_hash
  end

  def uri_params(request_uri)
    request_uri.split('?')[1].split('&')
  end

  # def create_session
  #   cgi = CGI.new('html4')

  #   begin
  #     session = CGI::Session.new(cgi, 'new_session' => false)
  #     session.delete
  #   rescue ArgumentError  # if no old session
  #   end

  #   session = CGI::Session.new(cgi, 'new_session' => true)
  #   session.close
  # end

  # def build_session
  #   cgi = CGI.new('html4')
  #   session = CGI::Session.new(cgi)

  #   session['game'] = @game
  # end

  # def set_session_id(cgi, session)
  #   if cgi.has_key?('id') and cgi['id'] != ''
  #     session = cgi['user_name'].to_s
  #   elsif !session['id']
  #     session['id'] = @games.length + 1
  #   end
  # end

  # def find_game(id)
  #   if @games.has_key?(id)
  #     @games[id]
  #   else
  #     @games[id] = Game.new(session)
  #   end
  # end

end