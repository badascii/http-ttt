require 'minitest/autorun'
require 'minitest/spec'
require 'erb'
require_relative '../lib/game.rb'

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

  def test_grid_full
    assert_equal(false, @game.grid_full?)

    # This code block fills the grid with moves
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

  def test_four_in_a_row_cpu
    assert(!@game.four_in_a_row?(@cpu))

    @game.grid['a1'] = @cpu
    @game.grid['a2'] = @cpu
    @game.grid['a3'] = @cpu
    @game.grid['a4'] = @cpu

    assert(@game.four_in_a_row?(@cpu))
  #   @game.grid['b1'] = @cpu
  #   @game.grid['b2'] = @cpu
  #   @game.grid['b3'] = @cpu
  #   assert(@game.four_in_a_row?(@cpu, ['b1', 'b2', 'b3']))
  #   @game.grid['c1'] = @cpu
  #   @game.grid['c2'] = @cpu
  #   @game.grid['c3'] = @cpu
  #   assert(@game.four_in_a_row?(@cpu, ['c1', 'c2', 'c3']))
  #   @game.grid['a1'] = @cpu
  #   @game.grid['b1'] = @cpu
  #   @game.grid['c1'] = @cpu
  #   assert(@game.four_in_a_row?(@cpu, ['a1', 'b1', 'c1']))
  #   @game.grid['a2'] = @cpu
  #   @game.grid['b2'] = @cpu
  #   @game.grid['c2'] = @cpu
  #   assert(@game.four_in_a_row?(@cpu, ['a2', 'b2', 'c2']))
  #   @game.grid['a3'] = @cpu
  #   @game.grid['b3'] = @cpu
  #   @game.grid['c3'] = @cpu
  #   assert(@game.four_in_a_row?(@cpu, ['a3', 'b3', 'c3']))
  end

  def test_win
    @game.grid.keys.each do |position|
      @game.grid[position] = @game.player_1
    end

    assert(@game.win?(@game.player_1))
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

  def test_cpu_side_defense_4x4
    assert(!@game.side_defense_4x4?)

    @game.grid['a1'] = @game.player_1
    @game.grid['a2'] = @game.player_1
    @game.grid['b1'] = @game.cpu
    @game.grid['b2'] = @game.cpu

    assert(@game.side_defense_4x4?)
  end

  def test_cpu_opposite_corners_4x4_1
    assert(!@game.opposite_corners_4x4?)

    @game.grid['a1'] = @game.player_1
    @game.grid['c4'] = @game.player_1

    assert(@game.opposite_corners_4x4?)
  end

  def test_cpu_opposite_corners_4x4_2
    assert(!@game.opposite_corners_4x4?)

    @game.grid['a4'] = @game.player_1
    @game.grid['c1'] = @game.player_1

    assert(@game.opposite_corners_4x4?)
  end

end
