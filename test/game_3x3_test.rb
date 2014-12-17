require 'minitest/autorun'
require 'minitest/spec'
require 'erb'
require_relative '../lib/game'

class TestGame < MiniTest::Test

  def setup
    opts = { size: '3x3',
             mode: 'cpu' }
    @game = Game.new(opts)
  end

  def teardown
    # @game.grid = @game.get_grid
    # @game.grid = Game::GRID_3X3

    @game.grid.keys.each do |position|
      @game.grid[position] = ' '
    end
  end

  def test_build_3x3_template
    expected_view = File.read('./test/test_3x3_view.html')

    assert_equal(expected_view, @game.build_template)
  end

  def test_grid
    assert_equal(@game.grid.class, Hash)
    assert_equal(@game.grid.length, 9)
  end

  def test_get_grid
    grid = @game.get_grid

    assert_equal(Game::GRID_3X3, grid)
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

  def test_position_empty
    assert(@game.position_empty?('a1'))
    assert(@game.position_empty?('b2'))
    assert(@game.position_empty?('c3'))
  end

  def test_valid_position_format
    if @size == '3x3'
      (position =~ POSITION_REGEX_3X3) || (position =~ POSITION_REGEX_REVERSE_3X3)
    elsif @size == '4x4'
      (position =~ POSITION_REGEX_4X4) || (position =~ POSITION_REGEX_REVERSE_4X4)
    end
  end

  def test_grid_full
    assert_equal(false, @game.grid_full?)

    @game.grid.keys.each do |position|
      @game.grid[position] = @game.player_1
    end

    assert_equal(true, @game.grid_full?)
  end

  def test_player_three_in_a_row_1
    assert(!@game.three_in_a_row?(@player_1))

    @game.grid['a1'] = @player_1
    @game.grid['a2'] = @player_1
    @game.grid['a3'] = @player_1

    assert(@game.three_in_a_row?(@player_1))
  end

  def test_player_three_in_a_row_2
    assert(!@game.three_in_a_row?(@player_1))

    @game.grid['b1'] = @player_1
    @game.grid['b2'] = @player_1
    @game.grid['b3'] = @player_1

    assert(@game.three_in_a_row?(@player_1))
  end

  def test_player_three_in_a_row_3
    assert(!@game.three_in_a_row?(@player_1))

    @game.grid['c1'] = @player_1
    @game.grid['c2'] = @player_1
    @game.grid['c3'] = @player_1
    assert(@game.three_in_a_row?(@player_1))
  end

  def test_player_three_in_a_row_4
    assert(!@game.three_in_a_row?(@player_1))

    @game.grid['a1'] = @player_1
    @game.grid['b1'] = @player_1
    @game.grid['c1'] = @player_1
    assert(@game.three_in_a_row?(@player_1))
  end

  def test_player_three_in_a_row_5
    assert(!@game.three_in_a_row?(@player_1))

    @game.grid['a2'] = @player_1
    @game.grid['b2'] = @player_1
    @game.grid['c2'] = @player_1
    assert(@game.three_in_a_row?(@player_1))
  end

  def test_player_three_in_a_row_6
    assert(!@game.three_in_a_row?(@player_1))

    @game.grid['a3'] = @player_1
    @game.grid['b3'] = @player_1
    @game.grid['c3'] = @player_1
    assert(@game.three_in_a_row?(@player_1))
  end

  def test_cpu_three_in_a_row_1
    assert(!@game.three_in_a_row?(@cpu))

    @game.grid['a1'] = @cpu
    @game.grid['a2'] = @cpu
    @game.grid['a3'] = @cpu

    assert(@game.three_in_a_row?(@cpu))
  end

  def test_cpu_three_in_a_row_2
    assert(!@game.three_in_a_row?(@cpu))

    @game.grid['b1'] = @cpu
    @game.grid['b2'] = @cpu
    @game.grid['b3'] = @cpu

    assert(@game.three_in_a_row?(@cpu))
  end

  def test_cpu_three_in_a_row_3
    assert(!@game.three_in_a_row?(@cpu))

    @game.grid['c1'] = @cpu
    @game.grid['c2'] = @cpu
    @game.grid['c3'] = @cpu

    assert(@game.three_in_a_row?(@cpu))
  end

  def test_cpu_three_in_a_row_4
    assert(!@game.three_in_a_row?(@cpu))

    @game.grid['a1'] = @cpu
    @game.grid['b1'] = @cpu
    @game.grid['c1'] = @cpu

    assert(@game.three_in_a_row?(@cpu))
  end

  def test_cpu_three_in_a_row_5
    assert(!@game.three_in_a_row?(@cpu))

    @game.grid['a2'] = @cpu
    @game.grid['b2'] = @cpu
    @game.grid['c2'] = @cpu

    assert(@game.three_in_a_row?(@cpu))
  end

  def test_cpu_three_in_a_row_6
    assert(!@game.three_in_a_row?(@cpu))

    @game.grid['a3'] = @cpu
    @game.grid['b3'] = @cpu
    @game.grid['c3'] = @cpu

    assert(@game.three_in_a_row?(@cpu))
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
    @game.grid['c1'] = @game.player_1
    @game.grid['c2'] = @game.player_1

    win  = @game.cpu_check_for_win(@game.cpu)
    loss = @game.cpu_check_for_win(@game.player_1)

    assert_equal('a3', win)
    assert_equal('c3', loss)
  end

  def test_get_win_conditions
    assert_equal(Game::WIN_CONDITIONS_3X3, @game.get_win_conditions)
  end

  def test_get_win_length
    assert_equal(2, @game.get_win_length)
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
  end

  def test_cpu_side_defense_3x3
    assert(!@game.side_defense_3x3?)
    @game.grid['a1'] = @game.player_1
    @game.grid['a2'] = @game.player_1
    @game.grid['b1'] = @game.cpu
    @game.grid['b2'] = @game.cpu
    assert(@game.side_defense_3x3?)
  end

  def test_cpu_opposite_corners_1
    assert(!@game.opposite_corners?)
    @game.grid['a1'] = @game.player_1
    @game.grid['c3'] = @game.player_1
    assert(@game.opposite_corners?)
  end

  def test_cpu_opposite_corners_2
    assert(!@game.opposite_corners?)
    @game.grid['a3'] = @game.player_1
    @game.grid['c1'] = @game.player_1
    assert(@game.opposite_corners?)
  end

  def test_find_empty_position
    assert_equal(' ', @game.grid['c3'])

    @game.find_empty_position

    assert_equal(@game.cpu, @game.grid['c3'])
  end

  def test_cpu_results
    expected_result = 'You lose. Really?'

    @game.grid.keys.each do |position|
      @game.grid[position] = @game.cpu
    end

    result = @game.cpu_results

    assert_equal(expected_result, result)
  end

  def test_human_results
    expected_result = 'X wins! Congrats!'

    opts   = { size: '3x3',
               mode: 'human' }
    game   = Game.new(opts)

    game.grid.keys.each do |position|
      game.grid[position] = game.player_1
    end

    result = game.human_results

    assert_equal(expected_result, result)
  end
end
