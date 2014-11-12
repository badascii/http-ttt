require 'socket'
require 'uri'
require 'gserver'
require 'erb'
require 'cgi'
require 'cgi/session'

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
    @game      = Game.new(session['game'])
    @session ||= CGI.new("html4")
  end

  def serve(client)
    loop do

      write_index
      line = client.readline
      path = requested_file(line)
      path = File.join(path, 'index.html') if File.directory?(path)
      get_game_template if path == 'game.html'

      puts line
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

  def get_game_template
    template = %q{
      <html>
        <body>
          <h1>Tic-Tac-Toe</h1>
          <% if @game.mode == 'human' %>
            <%= '<h3>Human vs Human. Fight!</h3>' %>
              <% if @game.turn == @game.player_2 %>
                <%= '<h4>Player 2 Turn</h4>' %>
              <% else %>
                <%= '<h4>Player 1 Turn</h4>' %>
              <% end %>
          <% elsif @game.mode == 'cpu' %>
            <%= '<h3>Human vs CPU. Good luck!</h3>' %>
          <% end %>

          <% if @game.size == '3x3' %>
            <%= '<h3>3x3</h3>' %>
          <% elsif @game.size == '4x4' %>
            <%= '<h3>4x4</h3>' %>
          <% end %>

          <table id='grid'>
            <tr>
              <td> </td>
              <td>A</td>
              <td>B</td>
              <td>C</td>
              <% if @game.grid['d1'] %>
                <td>D</td>
              <% end %>
            </tr>
            <tr>
              <td>1</td>
              <td id='a1'> <%= @game.grid['a1'] %> </td>
              <td id='b1'> <%= @game.grid['b1'] %> </td>
              <td id='c1'> <%= @game.grid['c1'] %> </td>
              <% if @game.grid['d1'] %>
                <%= "<td id='d1'>#{@game.grid['d1']} </td>" %>
              <% end %>
            </tr>
            <tr>
              <td>2</td>
              <td id='a2'> <%= @game.grid['a2'] %> </td>
              <td id='b2'> <%= @game.grid['b2'] %> </td>
              <td id='c2'> <%= @game.grid['c2'] %> </td>
              <% if @game.grid['d2'] %>
                <%= "<td id='d2'>#{@game.grid['d2']} </td>" %>
              <% end %>
            </tr>
            <tr>
              <td>3</td>
              <td id='a3'> <%= @game.grid['a3'] %> </td>
              <td id='b3'> <%= @game.grid['b3'] %> </td>
              <td id='c3'> <%= @game.grid['c3'] %> </td>
              <% if @game.grid['d3'] %>
                <%= "<td id='d3'>#{@game.grid['d3']} </td>" %>
              <% end %>
            </tr>
            <% if @game.grid['a4'] %>
              <td>4</td>
              <td id='a4'> <%= @game.grid['a4'] %> </td>
              <td id='b4'> <%= @game.grid['b4'] %> </td>
              <td id='c4'> <%= @game.grid['c4'] %> </td>
              <td id='d4'> <%= @game.grid['d4'] %> </td>
            <% end %>
          </table>
          </br>
          <% if @game.grid.has_value?(' ') || @game.grid.has_value?(0)%>
            <form method='post' action='/game/move'>
              <label for='grid_position'>Grid position:</label>
              <input type='text' name='grid_position' id='grid_position' autofocus />
              <input type='submit' value='Submit' />
            </form>
          <% end %>

          <%= @game.message %>
          <% if @player_move && !@player_move.empty? %>
            <%= "Your input was #{@player_move.upcase}." %>
          <% end %>
        </body>
      </html>
    }

    File.open('../public/game.html', 'w') do |file|
      puts file.write(ERB.new(template, 0, "%<>"))
    end
  end

end