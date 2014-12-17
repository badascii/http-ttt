require 'erb'

class Game

  GRID_3X3 = {
    'a1' => ' ', 'b1' => ' ', 'c1' => ' ',
    'a2' => ' ', 'b2' => ' ', 'c2' => ' ',
    'a3' => ' ', 'b3' => ' ', 'c3' => ' '}

  GRID_4X4 = {
    'a1' => ' ', 'b1' => ' ', 'c1' => ' ', 'd1' => ' ',
    'a2' => ' ', 'b2' => ' ', 'c2' => ' ', 'd2' => ' ',
    'a3' => ' ', 'b3' => ' ', 'c3' => ' ', 'd3' => ' ',
    'a4' => ' ', 'b4' => ' ', 'c4' => ' ', 'd4' => ' '}

  WIN_CONDITIONS_3X3 = [
    ['a1', 'a2', 'a3'], # 0 vertical win
    ['b1', 'b2', 'b3'], # 1 vertical win
    ['c1', 'c2', 'c3'], # 2 vertical win
    ['a1', 'b1', 'c1'], # 3 horizontal win
    ['a2', 'b2', 'c2'], # 4 horizontal win
    ['a3', 'b3', 'c3'], # 5 horizontal win
    ['a1', 'b2', 'c3'], # 6 diagonal win
    ['a3', 'b2', 'c1']] # 7 diagonal win

  WIN_CONDITIONS_4X4 = [
    ['a1', 'a2', 'a3', 'a4'], # 0 vertical win
    ['b1', 'b2', 'b3', 'b4'], # 1 vertical win
    ['c1', 'c2', 'c3', 'c4'], # 2 vertical win
    ['d1', 'd2', 'd3', 'd4'], # 3 vertical win
    ['a1', 'b1', 'c1', 'd1'], # 4 horizontal win
    ['a2', 'b2', 'c2', 'd2'], # 5 horizontal win
    ['a3', 'b3', 'c3', 'd3'], # 6 horizontal win
    ['a4', 'b4', 'c4', 'd4'], # 7 horizontal win
    ['a1', 'b2', 'c3', 'd4'], # 8 diagonal win
    ['a4', 'b3', 'c2', 'd1']] # 9 diagonal win

  POSITION_REGEX_3X3         = /[abc][1-3]/i
  POSITION_REGEX_REVERSE_3X3 = /[1-3][abc]/i
  POSITION_REGEX_4X4         = /[abcd][1-4]/i
  POSITION_REGEX_REVERSE_4X4 = /[1-4][abcd]/i

  attr_accessor :grid, :player_1, :player_2, :cpu, :mode, :size, :turn, :message, :result, :id

  def initialize(opts)
    @player_1 = 'X'
    @player_2 = 'O'
    @cpu      = 'O'
    @size     = opts[:size]
    @mode     = opts[:mode]
    @turn     = opts[:turn] || @player_1
    @grid     = get_grid
    @result   = nil
    @message  = opts[:message] || 'Welcome to the Fields of Strife'
    @id       = opts[:id] || '1'
  end

  def round(position)
    if @mode == 'human'
      get_player_input(position)
      human_results
    elsif @mode == 'cpu'
      get_player_input(position)
      cpu_results
    end
  end

  def get_player_input(position)
    if valid_move?(position)
      process_move(position)
    elsif valid_position_format?(position)
      @message = 'Invalid input. That position is taken.'
    else
      @message = 'Invalid input. That is not a valid position.'
    end
  end

  def valid_move?(position)
    (valid_position_format?(position)) && (@grid[position.downcase] == ' ')
  end

  def valid_position_format?(position)
    if @size == '3x3'
      (position =~ POSITION_REGEX_3X3) || (position =~ POSITION_REGEX_REVERSE_3X3)
    elsif @size == '4x4'
      (position =~ POSITION_REGEX_4X4) || (position =~ POSITION_REGEX_REVERSE_4X4)
    end
  end

  def process_move(position)
    @grid[position.downcase] = @turn
    @message = 'Move accepted.'
    if @mode == 'cpu'
      cpu_turn if !grid_full?
    else
      switch_turns
    end
  end

  def switch_turns
    if @turn == @player_1
      @turn = @player_2
    elsif @turn == @player_2
      @turn = @player_1
    end
  end

  def human_results
    if win?(@player_1)
      @result = "#{@player_1} wins! Congrats!"
    elsif win?(@cpu)
      @result = "#{@player_2} wins! Congrats!"
    elsif grid_full?
      @result = 'Stalemate'
    end
  end

  def cpu_results
    if win?(@player_1)
      @result = 'You win. Congrats!'
    elsif win?(@cpu)
      @result = 'You lose. Really?'
    elsif grid_full?
      @result = 'Stalemate'
    end
  end

  def win?(mark)
    if @size == '3x3'
      three_in_a_row?(mark)
    elsif @size == '4x4'
      four_in_a_row?(mark)
    end
  end

  def three_in_a_row?(mark)
    WIN_CONDITIONS_3X3.each do |win_condition|
      return true if (@grid[win_condition[0]] == mark) && (@grid[win_condition[1]] == mark) && (@grid[win_condition[2]] == mark)
    end
    return false
  end

  def four_in_a_row?(mark)
    WIN_CONDITIONS_4X4.each do |win_condition|
      return true if (@grid[win_condition[0]] == mark) && (@grid[win_condition[1]] == mark) && (@grid[win_condition[2]] == mark) && (@grid[win_condition[3]] == mark)
    end
    return false
  end

  def get_grid
    if @size == '4x4'
      GRID_4X4.dup
    else
      GRID_3X3.dup
    end
  end

  def start_of_game?
    @grid.values.uniq.length == 2
  end

  def grid_full?
    !@grid.has_value?(' ')
  end

  def cpu_turn
    win  = cpu_check_for_win(@cpu)
    loss = cpu_check_for_win(@player_1)

    if start_of_game?
      opening_move
    elsif win
      @grid[win] = @cpu
    elsif loss
      @grid[loss] = @cpu
    elsif corner_defense?
      place_corner_defense
    elsif (side_defense_3x3? || side_defense_4x4?)
      place_side_defense
    elsif (opposite_corners? && @size == '3x3')
      @grid['a2'] = @cpu
    else
      optimal_move
    end
  end

  def cpu_check_for_win(mark)
    move           = nil
    win_conditions = get_win_conditions
    win_length     = get_win_length

    win_conditions.each do |condition|
      occupied_spaces = []
      open_space = false
      condition.each do |position|
        open_space = true if position_empty?(position)
        occupied_spaces << position if @grid[position] == mark
      end
      if occupied_spaces.length == win_length && open_space == true
        move = condition - occupied_spaces
        return move.first
      end
    end
    return move
  end

  def get_win_conditions
    if @size == '3x3'
      WIN_CONDITIONS_3X3.dup
    elsif @size == '4x4'
      WIN_CONDITIONS_4X4.dup
    end
  end

  def get_win_length
    if @size == '3x3'
      2
    elsif @size == '4x4'
      3
    end
  end

  def opening_move
    if position_empty?('b2')
      @grid['b2'] = @cpu
    else
      @grid['a1'] = @cpu
    end
  end

  def place_side_defense
    if @grid['a2'] == ' '
      @grid['a2'] = @cpu
    elsif @grid['b1'] == ' '
      @grid['b1'] = @cpu
    elsif @grid['b3'] == ' '
      @grid['b3'] = @cpu
    elsif @grid['c2'] == ' '
      @grid['c2'] = @cpu
    else
      optimal_move
    end
  end

  def place_corner_defense
    if @grid['a1'] == ' '
      @grid['a1'] = @cpu
    elsif @grid['c1'] == ' '
      @grid['c1'] = @cpu
    elsif @grid['a3'] == ' '
     @grid['a3'] = @cpu
    elsif @grid['c3'] == ' '
      @grid['c3'] = @cpu
    else
      optimal_move
    end
  end

  def optimal_move
    if position_empty?('b1') && position_empty?('b3')
      @grid['b3'] = @cpu
    elsif position_empty?('a2') && position_empty?('c2')
      @grid['c2'] = @cpu
    else
      find_empty_position
    end
  end

  def position_empty?(position)
    @grid[position] == ' '
  end

  def find_empty_position
    @grid.keys.reverse.each do |key|
      if @grid[key] == ' '
        @grid[key] = @cpu
        break
      end
    end
  end

  def corner_defense?
    side_positions = [@grid['a2'], @grid['b1'], @grid['b3'], @grid['c2']]
    side_positions.count(' ') == 1
  end

  def side_defense_3x3?
    corner_positions = [@grid['a1'], @grid['a3'], @grid['c1'], @grid['c3']]
    side_positions   = [@grid['a2'], @grid['b1'], @grid['b3'], @grid['c2']]

    (@grid['b2'] == @cpu) && (corner_positions.uniq.count == 2) && (side_positions.uniq.count == 3)
  end

  def side_defense_4x4?
    corner_positions = [@grid['a1'], @grid['a4'], @grid['d1'], @grid['d4']]
    side_positions   = [@grid['a2'], @grid['a3'], @grid['b1'], @grid['b4'],
                        @grid['c1'], @grid['c4'], @grid['d2'], @grid['d3']]

    (@grid['b2'] == @cpu) && (corner_positions.uniq.count == 2) && (side_positions.uniq.count == 3)
  end

  def opposite_corners?
    (@grid['a1'] == @player_1 && @grid['c3'] == @player_1) ||
    (@grid['a3'] == @player_1 && @grid['c1'] == @player_1)
  end

  def write_template(path)
    html = build_template
    File.write(path, html)
  end

  def build_template
    erb      = File.read('./lib/template.erb')
    template = ERB.new(erb)
    html     = template.result(get_binding)

    return html
  end

  def get_binding
    binding
  end

end
