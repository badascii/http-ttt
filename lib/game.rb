require_relative 'game_3x3.rb'
require_relative 'game_4x4.rb'

class Game

  attr_accessor :grid, :player_1, :player_2, :cpu, :mode, :size, :turn, :message, :result, :id

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
    @id       = opts[:id] || '1'
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
    @id      = game.id
  end

  def session_hash
    {
      size:    @size,
      mode:    @mode,
      turn:    @turn,
      message: @message,
      result:  @result,
      grid:    @grid,
      id:      @id
    }
  end

  def build_template
    erb      = File.read('./lib/template.erb')
    template = ERB.new(erb)
    html     = template.result(get_binding)

    return html
  end

  def write_template(path)
    html = build_template
    File.write(path, html)
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

end
