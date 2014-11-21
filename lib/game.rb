require_relative 'game_3x3.rb'
require_relative 'game_4x4.rb'

class Game

  attr_accessor :grid, :player_1, :player_2, :cpu, :mode, :size, :turn, :message, :result

  def initialize(opts)
    @size     = opts[:size]
    @mode     = opts[:mode]
    @turn     = opts[:turn]
    @grid     = opts[:grid] || get_grid(@size)
    @player_1 = 'X'
    @player_2 = 'O'
    @cpu      = 'O'
    @result   = nil
    @message  = opts[:message] || 'Welcome to the Fields of Strife'
  end

  def round(position)
    game     = game_class.new(session_hash)
    game.round(position)
    @grid    = game.grid
    @mode    = game.mode
    @size    = game.size
    @turn    = game.turn
    @message = game.message
    @result  = game.result
  end

  def session_hash
    {
      size: @size,
      mode: @mode,
      turn: @turn,
      message: @message,
      result: @result,
      grid: @grid
    }
  end

  def write_template
    html = ERB.new(GAME_TEMPLATE)
    File.write('./public/game.html', html.result(get_binding))
  end

  private

  def game_class
    if @size == '4x4'
      Game4x4
    else
      Game3x3
    end
  end

  def get_grid(size)
    if size == '4x4'
      Game4x4::GRID
    else
      Game3x3::GRID
    end
  end

  def get_binding
    binding
  end

  GAME_TEMPLATE = %q{
     <html>
       <body>
         <h1>Tic-Tac-Toe</h1>
         <% if @mode == 'human' %>
           <%= '<h3>Human vs Human. Fight!</h3>' %>
             <% if @turn == @player_2 %>
               <%= '<h4>Player 2 Turn</h4>' %>
             <% else %>
               <%= '<h4>Player 1 Turn</h4>' %>
             <% end %>
         <% elsif @mode == 'cpu' %>
           <%= '<h3>Human vs CPU. Good luck!</h3>' %>
         <% end %>
         <% if @size == '3x3' %>
           <%= '<h3>3x3</h3>' %>
         <% elsif @size == '4x4' %>
           <%= '<h3>4x4</h3>' %>
         <% end %>
         <table id='grid'>
           <tr>
             <td> </td>
             <td>A</td>
             <td>B</td>
             <td>C</td>
             <% if @grid['d1'] %>
               <td>D</td>
             <% end %>
           </tr>
           <tr>
             <td>1</td>
             <td id='a1'> <%= @grid['a1'] %> </td>
             <td id='b1'> <%= @grid['b1'] %> </td>
             <td id='c1'> <%= @grid['c1'] %> </td>
             <% if @grid['d1'] %>
               <%= "<td id='d1'>#{@grid['d1']} </td>" %>
             <% end %>
           </tr>
           <tr>
             <td>2</td>
             <td id='a2'> <%= @grid['a2'] %> </td>
             <td id='b2'> <%= @grid['b2'] %> </td>
             <td id='c2'> <%= @grid['c2'] %> </td>
             <% if @grid['d2'] %>
               <%= "<td id='d2'>#{@grid['d2']} </td>" %>
             <% end %>
           </tr>
           <tr>
             <td>3</td>
             <td id='a3'> <%= @grid['a3'] %> </td>
             <td id='b3'> <%= @grid['b3'] %> </td>
             <td id='c3'> <%= @grid['c3'] %> </td>
             <% if @grid['d3'] %>
               <%= "<td id='d3'>#{@grid['d3']} </td>" %>
             <% end %>
           </tr>
           <% if @grid['a4'] %>
             <td>4</td>
             <td id='a4'> <%= @grid['a4'] %> </td>
             <td id='b4'> <%= @grid['b4'] %> </td>
             <td id='c4'> <%= @grid['c4'] %> </td>
             <td id='d4'> <%= @grid['d4'] %> </td>
           <% end %>
         </table>
         </br>
         <% if @grid.has_value?(' ') || @grid.has_value?(0)%>
           <form method='post' action='/game.html'>
             <label for='grid_position'>Grid position:</label>
             <input type='text' name='grid_position' id='grid_position' autofocus />
             <input type='submit' value='Submit' />
           </form>
         <% end %>
         <%= @message %>
       </body>
     </html>
   }

end
