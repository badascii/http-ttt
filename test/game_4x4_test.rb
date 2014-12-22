require 'minitest/autorun'
require 'minitest/spec'
require 'erb'
require_relative '../lib/game'

class TestGame < MiniTest::Test

  def setup
    opts = { size: '4x4',
             mode: 'cpu' }
    @game = Game.new(opts)
  end

  def teardown
    # @game.grid = @game.get_grid
    # @game.grid = Game::GRID_4X4

    @game.grid.keys.each do |position|
      @game.grid[position] = ' '
    end
  end

  def test_build_4x4_template
    expected_view = File.read('./test/test_4x4_view.html')

    assert_equal(expected_view, @game.build_template)
  end

  def test_grid
    assert_equal(@game.grid.class, Hash)
    assert_equal(@game.grid.length, 16)
  end

  def test_get_grid
    grid = @game.get_grid

    assert_equal(Game::GRID_4X4, grid)
  end

  def test_setting_grid
    @game.grid['a1'] = @game.player_1
    assert_equal(@game.grid['a1'], @game.player_1)
  end

  def test_marks
    assert(@game.player_1 != @game.cpu)
    assert_equal(@game.player_1, 'X')
    assert_equal(@game.cpu, 'O')
  end

  def test_valid_player_input
    expected_message = 'Move accepted.'

    @game.get_player_input('a1')

    assert_equal(expected_message, @game.message)
    assert_equal('X', @game.grid['a1'])
  end

  def test_player_input_position_taken
    expected_message       = 'Invalid input. That position is taken.'
    @game.grid['a1']       = @game.cpu
    position_taken_message = @game.get_player_input('a1')

    assert_equal(expected_message, position_taken_message)
  end

  def test_invalid_player_input
    expected_message       = 'Invalid input. That is not a valid position.'
    invalid_input_message  = @game.get_player_input('asdf')

    assert_equal(expected_message, invalid_input_message)
  end

  def test_position_empty
    assert(@game.position_empty?('a1'))
    assert(@game.position_empty?('b2'))
    assert(@game.position_empty?('c3'))
  end

  def test_valid_position_format
    valid_position   = @game.valid_position_format?('a1')
    invalid_position = @game.valid_position_format?('z9')

    assert_equal(0, valid_position)
    assert_equal(nil, invalid_position)
  end

  def test_process_move
    opts = { size: '4x4',
             mode: 'human' }
    game = Game.new(opts)

    game.process_move('a1')
    game.process_move('b2')

    assert_equal('X', game.grid['a1'])
    assert_equal('O', game.grid['b2'])
  end

  def test_grid_full
    assert_equal(false, @game.grid_full?)

    @game.grid.keys.each do |position|
      @game.grid[position] = @game.player_1
    end
    assert_equal(true, @game.grid_full?)
  end

  def test_four_in_a_row_player_1
    assert(!@game.four_in_a_row?(@player_1))
    @game.grid['a1'] = @player_1
    @game.grid['a2'] = @player_1
    @game.grid['a3'] = @player_1
    @game.grid['a4'] = @player_1

    assert(@game.four_in_a_row?(@player_1))
  end

  def test_player_four_in_a_row_2
    assert(!@game.four_in_a_row?(@player_1))

    @game.grid['b1'] = @player_1
    @game.grid['b2'] = @player_1
    @game.grid['b3'] = @player_1
    @game.grid['b4'] = @player_1

    assert(@game.four_in_a_row?(@player_1))
  end

  def test_player_four_in_a_row_3
    assert(!@game.four_in_a_row?(@player_1))

    @game.grid['c1'] = @player_1
    @game.grid['c2'] = @player_1
    @game.grid['c3'] = @player_1
    @game.grid['c4'] = @player_1

    assert(@game.four_in_a_row?(@player_1))
  end

  def test_player_four_in_a_row_4
    assert(!@game.four_in_a_row?(@player_1))

    @game.grid['a1'] = @player_1
    @game.grid['b1'] = @player_1
    @game.grid['c1'] = @player_1
    @game.grid['d1'] = @player_1

    assert(@game.four_in_a_row?(@player_1))
  end

  def test_player_four_in_a_row_5
    assert(!@game.four_in_a_row?(@player_1))

    @game.grid['a2'] = @player_1
    @game.grid['b2'] = @player_1
    @game.grid['c2'] = @player_1
    @game.grid['d2'] = @player_1

    assert(@game.four_in_a_row?(@player_1))
  end

  def test_player_four_in_a_row_6
    assert(!@game.four_in_a_row?(@player_1))

    @game.grid['a3'] = @player_1
    @game.grid['b3'] = @player_1
    @game.grid['c3'] = @player_1
    @game.grid['d3'] = @player_1

    assert(@game.four_in_a_row?(@player_1))
  end

  def test_player_four_in_a_row_7
    assert(!@game.four_in_a_row?(@player_1))

    @game.grid['a4'] = @player_1
    @game.grid['b4'] = @player_1
    @game.grid['c4'] = @player_1
    @game.grid['d4'] = @player_1

    assert(@game.four_in_a_row?(@player_1))
  end

  def test_player_four_in_a_row_8
    assert(!@game.four_in_a_row?(@player_1))

    @game.grid['d1'] = @player_1
    @game.grid['d2'] = @player_1
    @game.grid['d3'] = @player_1
    @game.grid['d4'] = @player_1

    assert(@game.four_in_a_row?(@player_1))
  end

  def test_cpu_four_in_a_row_1
    assert(!@game.four_in_a_row?(@cpu))

    @game.grid['a1'] = @cpu
    @game.grid['a2'] = @cpu
    @game.grid['a3'] = @cpu
    @game.grid['a4'] = @cpu

    assert(@game.four_in_a_row?(@cpu))
  end

  def test_cpu_four_in_a_row_2
    assert(!@game.four_in_a_row?(@cpu))

    @game.grid['b1'] = @cpu
    @game.grid['b2'] = @cpu
    @game.grid['b3'] = @cpu
    @game.grid['b4'] = @cpu

    assert(@game.four_in_a_row?(@cpu))
  end

  def test_cpu_four_in_a_row_3
    assert(!@game.four_in_a_row?(@cpu))

    @game.grid['c1'] = @cpu
    @game.grid['c2'] = @cpu
    @game.grid['c3'] = @cpu
    @game.grid['c4'] = @cpu

    assert(@game.four_in_a_row?(@cpu))
  end

  def test_cpu_four_in_a_row_4
    assert(!@game.four_in_a_row?(@cpu))

    @game.grid['a1'] = @cpu
    @game.grid['b1'] = @cpu
    @game.grid['c1'] = @cpu
    @game.grid['d1'] = @cpu

    assert(@game.four_in_a_row?(@cpu))
  end

  def test_cpu_four_in_a_row_5
    assert(!@game.four_in_a_row?(@cpu))

    @game.grid['a2'] = @cpu
    @game.grid['b2'] = @cpu
    @game.grid['c2'] = @cpu
    @game.grid['d2'] = @cpu

    assert(@game.four_in_a_row?(@cpu))
  end

  def test_cpu_four_in_a_row_6
    assert(!@game.four_in_a_row?(@cpu))

    @game.grid['a3'] = @cpu
    @game.grid['b3'] = @cpu
    @game.grid['c3'] = @cpu
    @game.grid['d3'] = @cpu

    assert(@game.four_in_a_row?(@cpu))
  end

  def test_player_four_in_a_row_7
    assert(!@game.four_in_a_row?(@player_1))

    @game.grid['a4'] = @cpu
    @game.grid['b4'] = @cpu
    @game.grid['c4'] = @cpu
    @game.grid['d4'] = @cpu

    assert(@game.four_in_a_row?(@player_1))
  end


  def test_cpu_four_in_a_row_8
    assert(!@game.four_in_a_row?(@cpu))

    @game.grid['d1'] = @cpu
    @game.grid['d2'] = @cpu
    @game.grid['d3'] = @cpu
    @game.grid['d4'] = @cpu

    assert(@game.four_in_a_row?(@cpu))
  end

  def test_win
    @game.grid.keys.each do |position|
      @game.grid[position] = @game.player_1
    end

    assert(@game.win?(@game.player_1))
  end

  def test_cpu_check_for_win
    @game.grid['a1'] = @game.cpu
    @game.grid['a2'] = @game.cpu
    @game.grid['a3'] = @game.cpu
    @game.grid['d1'] = @game.player_1
    @game.grid['d2'] = @game.player_1
    @game.grid['d3'] = @game.player_1

    win  = @game.cpu_check_for_win(@game.cpu)
    loss = @game.cpu_check_for_win(@game.player_1)

    assert_equal('a4', win)
    assert_equal('d4', loss)
  end

  def test_get_win_conditions
    assert_equal(Game::WIN_CONDITIONS_4X4, @game.get_win_conditions)
  end

  def test_get_win_length
    assert_equal(3, @game.get_win_length)
  end

  def test_start_of_game
    assert_equal(true, @game.start_of_game?)

    @game.grid['a1'] = @game.cpu
    @game.grid['c3'] = @game.player_1

    assert_equal(false, @game.start_of_game?)
  end

  def test_cpu_opening_move
    assert_equal(@game.grid['b2'], ' ')
    @game.opening_move
    assert_equal(@game.grid['b2'], @game.cpu)
    @game.opening_move
    assert_equal(@game.grid['a1'], @game.cpu)
  end

  def test_cpu_optimal_move
    assert_equal(@game.grid['b1'], ' ')
    @game.optimal_move
    assert_equal(@game.grid['b3'], @game.cpu)
    assert_equal(@game.grid['c2'], ' ')
    @game.optimal_move
    assert_equal(@game.grid['c2'], @game.cpu)
    @game.grid['b2'] = @game.player_1
    @game.grid['b3'] = @game.player_1
    assert_equal(@game.grid['c2'], @game.cpu)
  end

  def test_cpu_place_side_defense
    assert_equal(@game.grid['a2'], ' ')
    @game.place_side_defense
    assert_equal(@game.grid['a2'], @game.cpu)
    assert_equal(@game.grid['b1'], ' ')
    @game.place_side_defense
    assert_equal(@game.grid['b1'], @game.cpu)
    assert_equal(@game.grid['b3'], ' ')
    @game.place_side_defense
    assert_equal(@game.grid['b3'], @game.cpu)
    assert_equal(@game.grid['c2'], ' ')
    @game.place_side_defense
    assert_equal(@game.grid['c2'], @game.cpu)
    @game.place_side_defense
    assert_equal(@game.grid['d4'], @game.cpu)
  end

  def test_place_corner_defense
    assert_equal(@game.grid['a1'], ' ')
    @game.place_corner_defense
    assert_equal(@game.grid['a1'], @game.cpu)
    assert_equal(@game.grid['c1'], ' ')
    @game.place_corner_defense
    assert_equal(@game.grid['c1'], @game.cpu)
    assert_equal(@game.grid['a3'], ' ')
    @game.place_corner_defense
    assert_equal(@game.grid['a3'], @game.cpu)
    assert_equal(@game.grid['c3'], ' ')
    @game.place_corner_defense
    assert_equal(@game.grid['c3'], @game.cpu)
    @game.place_corner_defense
    assert_equal(@game.grid['b3'], @game.cpu)
  end

  def test_cpu_side_defense_4x4
    assert(!@game.side_defense_4x4?)

    @game.grid['a1'] = @game.player_1
    @game.grid['a2'] = @game.player_1
    @game.grid['b1'] = @game.cpu
    @game.grid['b2'] = @game.cpu

    assert(@game.side_defense_4x4?)
  end

  def test_find_empty_position
    assert_equal(' ', @game.grid['d4'])

    @game.find_empty_position

    assert_equal(@game.cpu, @game.grid['d4'])
  end

    def test_cpu_results_1
    expected_result = 'You win. Congrats!'

    @game.grid.keys.each do |position|
      @game.grid[position] = @game.player_1
    end

    result = @game.cpu_results

    assert_equal(expected_result, result)
  end

  def test_cpu_results_2
    expected_result = 'You lose. Really?'

    @game.grid.keys.each do |position|
      @game.grid[position] = @game.cpu
    end

    result = @game.cpu_results

    assert_equal(expected_result, result)
  end

  def test_cpu_results_3
    expected_result  = 'Stalemate'

    @game.grid['a1'] = @game.cpu
    @game.grid['a2'] = @game.cpu
    @game.grid['a3'] = @game.player_1
    @game.grid['a4'] = @game.player_1
    @game.grid['b1'] = @game.player_1
    @game.grid['b2'] = @game.player_1
    @game.grid['b3'] = @game.cpu
    @game.grid['b4'] = @game.cpu
    @game.grid['c1'] = @game.cpu
    @game.grid['c2'] = @game.player_1
    @game.grid['c3'] = @game.cpu
    @game.grid['c4'] = @game.cpu
    @game.grid['d1'] = @game.cpu
    @game.grid['d2'] = @game.player_1
    @game.grid['d3'] = @game.cpu
    @game.grid['d4'] = @game.cpu

    result = @game.cpu_results

    assert_equal(expected_result, result)
  end

  def test_human_results_1
    expected_result = 'X wins! Congrats!'
    opts            = { size: '4x4',
                        mode: 'human' }
    game            = Game.new(opts)

    game.grid.keys.each do |position|
      game.grid[position] = game.player_1
    end

    result = game.human_results

    assert_equal(expected_result, result)
  end

  def test_human_results_2
    expected_result = 'O wins! Congrats!'
    opts            = { size: '3x3',
                        mode: 'human' }
    game            = Game.new(opts)

    game.grid.keys.each do |position|
      game.grid[position] = game.player_2
    end

    result = game.human_results

    assert_equal(expected_result, result)
  end

  def test_human_results_3
    expected_result = 'Stalemate'
    opts            = { size: '3x3',
                        mode: 'human' }
    game            = Game.new(opts)

    game.grid['a1'] = game.player_2
    game.grid['a2'] = game.player_2
    game.grid['a3'] = game.player_1
    game.grid['a4'] = game.player_1
    game.grid['b1'] = game.player_1
    game.grid['b2'] = game.player_1
    game.grid['b3'] = game.player_2
    game.grid['b4'] = game.player_2
    game.grid['c1'] = game.player_2
    game.grid['c2'] = game.player_1
    game.grid['c3'] = game.player_2
    game.grid['c4'] = game.player_2
    game.grid['d1'] = game.player_2
    game.grid['d2'] = game.player_1
    game.grid['d3'] = game.player_2
    game.grid['d4'] = game.player_2

    result = game.human_results

    assert_equal(expected_result, result)
  end

  def test_switch_turns
    assert_equal(@game.player_1, @game.turn)

    @game.switch_turns

    assert_equal(@game.player_2, @game.turn)

    @game.switch_turns

    assert_equal(@game.player_1, @game.turn)
  end
end
