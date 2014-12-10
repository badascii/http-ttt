class Game4x4

  GRID = {'a1' => 0, 'b1' => 0, 'c1' => 0, 'd1' => 0,
          'a2' => 0, 'b2' => 0, 'c2' => 0, 'd2' => 0,
          'a3' => 0, 'b3' => 0, 'c3' => 0, 'd3' => 0,
          'a4' => 0, 'b4' => 0, 'c4' => 0, 'd4' => 0}

  WIN_CONDITIONS = [
    ['a1', 'a2', 'a3', 'a4'], # 0 vertical win
    ['b1', 'b2', 'b3', 'b4'], # 1 vertical win
    ['c1', 'c2', 'c3', 'c4'], # 2 vertical win
    ['d1', 'd2', 'd3', 'd4'], # 3 vertical win
    ['a1', 'b1', 'c1', 'd1'], # 4 horizontal win
    ['a2', 'b2', 'c2', 'd2'], # 5 horizontal win
    ['a3', 'b3', 'c3', 'd3'], # 6 horizontal win
    ['a4', 'b4', 'c4', 'd4'], # 7 horizontal win
    ['a1', 'b2', 'c3', 'd4'], # 8 diagonal win
    ['a4', 'b3', 'c2', 'd1']  # 9 diagonal win
    ]

  POSITION_REGEX         = /[abcd][1-4]/i
  POSITION_REGEX_REVERSE = /[1-4][abcd]/i

  attr_accessor :grid, :player_1, :player_2, :cpu, :mode, :size, :turn, :message, :result, :id

  def initialize(opts)
    @player_1    = 'X'
    @player_2    = 'O'
    @cpu         = 'O'
    @grid        = opts[:grid]
    @mode        = opts[:mode]
    @size        = opts[:size]
    @turn        = opts[:turn] || @player_1
    @message     = opts[:message]
    @result      = nil
    @id          = opts[:id] || '1'
  end

 def round(position)
    if @mode == 'human'
      get_player_input(position)
      switch_turns
      human_results
    elsif @mode == 'cpu'
      get_player_input(position)
      human_results
    end
  end

  private

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

  def switch_turns
    if @turn == @player_1
      @turn = @player_2
    elsif @turn == @player_2
      @turn = @player_1
    end
  end

  def get_player_input(position)
    if valid_move?(position)
      @grid[position.downcase] = @turn
      @message = 'Movement accepted.'
      if @mode == 'cpu'
        cpu_turn
      end
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
    (position =~ POSITION_REGEX) || (position =~ POSITION_REGEX_REVERSE)
  end

  def grid_full?
    !@grid.has_value?(0)
  end

  def win?(mark)
    vertical_win?(mark) || horizontal_win?(mark) || diagonal_win?(mark)
  end

  def vertical_win?(mark)
    four_in_a_row?(mark, WIN_CONDITIONS[0]) ||
    four_in_a_row?(mark, WIN_CONDITIONS[1]) ||
    four_in_a_row?(mark, WIN_CONDITIONS[2]) ||
    four_in_a_row?(mark, WIN_CONDITIONS[3])
  end

  def horizontal_win?(mark)
    four_in_a_row?(mark, WIN_CONDITIONS[4]) ||
    four_in_a_row?(mark, WIN_CONDITIONS[5]) ||
    four_in_a_row?(mark, WIN_CONDITIONS[6]) ||
    four_in_a_row?(mark, WIN_CONDITIONS[7])
  end

  def diagonal_win?(mark)
    four_in_a_row?(mark, WIN_CONDITIONS[8]) ||
    four_in_a_row?(mark, WIN_CONDITIONS[9])
  end

  def four_in_a_row?(mark, win_condition)
    (@grid[win_condition[0]] == mark) &&
    (@grid[win_condition[1]] == mark) &&
    (@grid[win_condition[2]] == mark) &&
    (@grid[win_condition[3]] == mark)
  end

  def cpu_turn
    win  = cpu_check_for_win(@cpu)
    loss = cpu_check_for_win(@player_1)

    if start_of_game?
      opening_move
    elsif win
      @grid[win]  = @cpu
    elsif loss
      @grid[loss] = @cpu
    elsif corner_defense?
      place_corner_defense
    elsif side_defense?
      place_side_defense
    elsif opposite_corners?
      @grid['a2'] = @cpu
    else
      optimal_move
    end
  end

  def cpu_check_for_win(mark)
    move = nil
    WIN_CONDITIONS.each do |condition|
      occupied_spaces = []
      open_space = false
      condition.each do |position|
        open_space = true if position_empty?(position)
        occupied_spaces << position if @grid[position] == mark
      end
      if occupied_spaces.length == 3 && open_space == true
        move = condition - occupied_spaces
        return move.first
      end
    end
    return move
  end

 def start_of_game?
    @grid.values.uniq.length == 2
  end

  def opening_move
    if position_empty?('b2')
      @grid['b2'] = @cpu
    else
      @grid['a1'] = @cpu
    end
  end

  def optimal_move
    if position_empty?('b1') && position_empty?('b3')
      @grid['b3'] = @cpu
    elsif position_empty?('a2') && position_empty?('c2')
      @grid['c2'] = @cpu
    else
      @grid.each do |key, value|
        if value == 0
          @grid[key] = @cpu
          break
        end
      end
    end
  end

  def position_empty?(position)
    @grid[position] == 0
  end

  def corner_defense?
    side_positions = [@grid['a2'], @grid['b1'], @grid['b3'], @grid['c2']]
    side_positions.count(0) == 1
  end

  def place_corner_defense
    if @grid['a1'] == 0
      @grid['a1'] = @cpu
    elsif @grid['c1'] == 0
      @grid['c1'] = @cpu
    elsif @grid['a3'] == 0
     @grid['a3'] = @cpu
    elsif @grid['c3'] == 0
      @grid['c3'] = @cpu
    else
      optimal_move
    end
  end

  def side_defense?
    corner_positions = [@grid['a1'], @grid['a4'], @grid['d1'], @grid['d4']]
    side_positions   = [@grid['a2'], @grid['a3'], @grid['b1'], @grid['b4'], @grid['c1'], @grid['c4'], @grid['d2'], @grid['d3']]
    (@grid['b2'] == @cpu) && (corner_positions.uniq.count == 2) && (side_positions.uniq.count == 3)
  end

  def place_side_defense
    if @grid['a2'] == 0
      @grid['a2'] = @cpu
    elsif @grid['b1'] == 0
      @grid['b1'] = @cpu
    elsif @grid['b3'] == 0
      @grid['b3'] = @cpu
    elsif @grid['c2'] == 0
      @grid['c2'] = @cpu
    else
      optimal_move
    end
  end

  def opposite_corners?
    (@grid['a1'] == @player_1 && @grid['c4'] == @player_1) || (@grid['a4'] == @player_1 && @grid['c1'] == @player_1)
  end
end
