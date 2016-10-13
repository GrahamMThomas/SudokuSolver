require 'minitest/autorun'
require_relative 'sudoku_class'
require_relative 'sudoku_utils'

class SudokuTest < Minitest::Test
  @@puzzle = Sudoku.zero(9)
  @@puzzle.load_matrix_from_file('Puzzles/SudokuDefault.txt')
  @@hard_puzzle = Sudoku.zero(9)
  @@hard_puzzle.load_matrix_from_file('Puzzles/SudokuHard1.txt')

  def test_available_numbers_in_row_or_col_valid_col_success
    method_output = @@puzzle.available_numbers_in_row_or_col { |i, arr| arr.push(@@puzzle[0, i].to_s) } 
    method_expected = ['3','4','5','8','9']
    assert (method_output == method_expected),
           "Did not return expected numbers.\nExpected:#{method_expected}\nGot:#{method_output}"
  end

  def test_available_numbers_in_row_or_col_valid_row_success
    method_output = @@puzzle.available_numbers_in_row_or_col { |i,arr| arr.push(@@puzzle[i, 0].to_s) }
    method_expected = ['2','3','4','5','9']
    assert (method_output == method_expected),
           "Did not return expected numbers.\nExpected:#{method_expected}\nGot:#{method_output}"
  end

  def test_available_numbers_in_box_valid_success
    method_output = @@puzzle.available_numbers_in_box(0, 0)
    method_expected = ['2','3','4','5','7']
    assert (method_output == method_expected),
           "Did not return expected numbers.\nExpected:#{method_expected}\nGot:#{method_output}"
  end

  def test_calculate_possible_numbers_for_square_valid_success
    method_output = @@puzzle.calculate_possible_numbers_for_square(0, 0)
    method_expected = ['3','4','5']
    assert (method_output == method_expected),
           "Did not return expected numbers.\nExpected:#{method_expected}\nGot:#{method_output}"
  end

  def test_check_row_availability_for_square_valid_success
    @@hard_puzzle.calculate_possible_numbers_for_square(0,8)
    method_output = @@hard_puzzle.check_row_availability_for_square(0, 8)
    method_expected = ['3']
    assert (method_output == method_expected) , 
           "Did not return expected numbers.\nExpected:#{method_expected}\nGot:#{method_output}"
  end

  def test_check_col_availability_for_square_valid_success
    @@hard_puzzle.calculate_possible_numbers_for_square(0,8)
    method_output = @@hard_puzzle.check_col_availability_for_square(0, 8)
    method_expected = ['3']
    assert (method_output == method_expected),
           "Did not return expected numbers.\nExpected:#{method_expected}\nGot:#{method_output}"
  end

  def test_check_box_availability_for_square_valid_success
    @@hard_puzzle.calculate_possible_numbers_for_square(0, 8)
    method_output = @@hard_puzzle.check_box_availability_for_square(0, 8)
    method_expected = ['3']
    assert (method_output == method_expected),
           "Did not return expected numbers.\nExpected:#{method_expected}\nGot:#{method_output}"
  end

  def test_check_availability_for_square_valid_success
    @@hard_puzzle.calculate_possible_numbers_for_square(0, 8)
    method_output = @@hard_puzzle.check_availability_for_square(0, 8)
    method_expected = ['3']
    assert (method_output == method_expected),
           "Did not return expected numbers.\nExpected:#{method_expected}\nGot:#{method_output}"
  end

  def test_insert_number_into_blank_valid_success
    default_puzzle = Sudoku.zero(9).load_matrix_from_file('Puzzles/SudokuDefault.txt')
    default_puzzle.insert_number_into_blank(0, 0, 0)
    method_expected = 0
    assert (default_puzzle[0,0] == method_expected),
           "Did not return expected numbers.\nExpected:#{method_expected}\nGot:#{default_puzzle[0,0]}"
  end

  def test_insert_number_into_each_blank_valid_success
    default_puzzle = Sudoku.zero(9).load_matrix_from_file('Puzzles/SudokuDefault.txt')
    default_puzzle.calculate_possible_numbers_for_each_square
    default_puzzle.insert_number_into_each_blank
    method_expected = '3'
    assert (default_puzzle[0,1] == method_expected),
           "Did not return expected numbers.\nExpected:#{method_expected}\nGot:#{default_puzzle[0,1]}"
  end
end
