require 'socket'
require 'uri'
require 'gserver'
require 'erb'
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

  @@hash_of_games = {}

  def initialize(port=2000, *args)
    super(port, *args)
  end

  def serve(client)
    loop do
      line      = client.readline
      path      = requested_file(line)
      path      = File.join(path, 'index.html') if File.directory?(path)

      puts line

      if line.include?('POST')
        post_data = fetch_post_data(path, client)
        build_page(path, post_data)
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
    header  = build_header(404, 'text/plain', message.size)

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

  def fetch_post_data(path, client)
    line        = client.readline
    header_hash = {}

    until line =~ /^\R$/
      header_array = line.split(':')
      header_hash[header_array[0]] = header_array[1]
      line = client.readline
    end

    content_length = header_hash['Content-Length'].to_i
    post_data      = client.read(content_length)

    return post_data
  end

  def build_page(path, post_data)
    if path == './public/start.html'
      build_new_game(post_data)
    elsif path == './public/game.html'
      build_existing_game(post_data)
    end
  end

  def build_new_game(post_data)
    param_hash   = parse_param_string(post_data)
    game         = Game.new(param_hash)
    game.write_starting_template
    store_game(game)
  end

  def build_existing_game(post_data)
    param_hash   = parse_param_string(post_data)
    game         = retrieve_game(param_hash[:id])
    puts param_hash[:grid_position]
    game.round(param_hash[:grid_position])
    game.write_game_template
    store_game(game)
  end

  def parse_param_string(param_string)
    param_hash      = {}
    array_of_params = param_string.split('&')

    array_of_params.each do |param|
      key   = param.split('=')[0]
      value = param.split('=')[1]
      param_hash[key.to_sym] = value
    end

    return param_hash
  end

  def self.hash_of_games
    @@hash_of_games
  end

  def store_game(game)
    @@hash_of_games[game.id] = game
  end

  def retrieve_game(game_id)
    @@hash_of_games[game_id]
  end

  def self.clear_games
    @@hash_of_games = {}
  end

end