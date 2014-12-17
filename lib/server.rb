require 'socket'
require 'uri'
require 'gserver'
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
        process_post(path, client)
      end

      puts "Got request for: #{path}"
      send_response(path, client)
    end
  end

  def requested_file(line)
    request_uri = line.split(' ')[1]
    path        = URI.unescape(URI(request_uri).path)

    File.join(ROOT, path)
  end

  def content_type(path)
    ext = File.extname(path).split('.').last
    CONTENT_TYPES.fetch(ext, DEFAULT_CONTENT_TYPE)
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

  def process_post(path, client)
    post_data = fetch_post_data(client)
    params    = parse_param_string(post_data)

    build_page(path, params)
  end

  def fetch_post_data(client)
    content_length = get_content_length(client)
    post_data      = client.read(content_length)

    return post_data
  end

  def get_content_length(client)
    line        = client.readline
    header_hash = {}

    until line =~ /^\R$/
      header_array = line.split(':')
      header_hash[header_array[0]] = header_array[1]
      line = client.readline
    end

    return header_hash['Content-Length'].to_i
  end

  def parse_param_string(param_string)
    array_of_params = param_string.split('&')
    param_hash      = {}

    array_of_params.each do |param|
      key   = param.split('=')[0]
      value = param.split('=')[1]
      param_hash[key.to_sym] = value
    end

    return param_hash
  end

  def build_page(path, params)
    if path == './public/start.html'
      build_new_game(path, params)
    elsif path == './public/game.html'
      build_existing_game(path, params)
    end
  end

  def build_new_game(path, params)
    params[:id] = new_game_id.to_s
    game        = Game.new(params)

    game.write_template(path)
    store_game(game)
  end

  def new_game_id
    if @@hash_of_games.empty?
      return '1'
    else
      ids = []

      @@hash_of_games.keys.each do |key|
        ids << key.to_i
      end

      return ids.max + 1
    end
  end

  def build_existing_game(path, params)
    game = retrieve_game(params[:id])

    game.round(params[:grid_position])
    game.write_template(path)
    store_game(game)
  end

  def self.hash_of_games
    @@hash_of_games
  end

  def store_game(game)
    @@hash_of_games[game.id] = game
  end

  def retrieve_game(id)
    @@hash_of_games[id]
  end

  def self.clear_games
    @@hash_of_games = {}
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


end