require 'matrix'
require_relative 'sudoku_utils'

class Sudoku < Matrix
  # Stuck is a variable which turns to true with there
  # are no more easy insertions to be made.
  @stuck = FALSE

  # Solved is set to true when the advanced logic
  # can no longer insert any numbers.
  @solved = FALSE

  @@all_possible_numbers = %w(1 2 3 4 5 6 7 8 9)

  # Loads a string from a file and creates a matrix.
  def load_matrix_from_file(filename)
    file_contents = SudokuUtils.open_file(filename)
    SudokuUtils.LoopPuzzle do |row, col|
      self[row, col] = file_contents[0]
      file_contents[0] = ''
    end
    initialize_blanks
  end

  # Create an Element object in every blank square
  def initialize_blanks
    each_with_index do |blank_space, row, col|
      next unless blank_space == '-'
      blank_space = Element.new
      blank_space.possibleNumbers = []
      blank_space.relativeNumbers = []
      self[row, col] = blank_space
    end
  end

  #-----------------------------Simple Available Number Methods------------------------------
  # These methods simply find the numbers that are not located in a row, column, or box

  # This method takes a block which will push the row or column into an array.
  def available_numbers_in_row_or_col
    all_actual_numbers = []
    (0..9).each do |i|
      yield(i, all_actual_numbers)
    end
    @@all_possible_numbers - all_actual_numbers
  end

  # Returns all numbers not present in box of the square passed as a parameter
  def available_numbers_in_box(row, col)
    all_actual_numbers = []
    (0..2).each do |row_iterator|
      (0..2).each do |col_iterator|
        all_actual_numbers.push(self[row_iterator + 3 * (row / 3),
                                     col_iterator + 3 * (col / 3)].to_s)
      end
    end
    @@all_possible_numbers - all_actual_numbers
  end

  ##
  # This method will combine all methods for available numbers and will
  # return only numbers in all 3 outputs
  def calculate_possible_numbers_for_square(row, col)
    self[row, col].possibleNumbers =
      available_numbers_in_box(row, col) &
      available_numbers_in_row_or_col { |i, arr| arr.push(self[row, i].to_s) } &
      available_numbers_in_row_or_col { |i, arr| arr.push(self[i, col].to_s) }
  end

  # Loops through puzzle and run a method all all of the elements.
  def calculate_possible_numbers_for_each_square
    @stuck = TRUE
    SudokuUtils.LoopPuzzle do |row, col|
      if self[row, col].is_a? Element
        calculate_possible_numbers_for_square(row, col)
      end
    end
  end

  #---------------------------Check For Square Availability Based on Surrounding Squares------------------------------
  # These Methods will check to see if you can determine the value for a square by looking at the lanes around it.

  # Checks row to see if this square is the only square that can be a number.
  def check_row_availability_for_square(row, col)
    possible_for_row = []
    (0..8).each do |i|
      if (self[row, i].is_a? Element) && i != col
        possible_for_row |= calculate_possible_numbers_for_square(row, i)
      end
    end
    self[row, col].possibleNumbers - possible_for_row
  end

  # Checks column to see if this square is the only square that can be a number.
  def check_col_availability_for_square(row, col)
    possible_for_col = []
    (0..8).each do |i|
      if (self[i, col].is_a? Element) && i != row
        possible_for_col |= calculate_possible_numbers_for_square(i, col)
      end
    end
    self[row, col].possibleNumbers - possible_for_col
  end

  # Checks box to see if this square is the only square that can be a number.
  def check_box_availability_for_square(row, col)
    possible_for_box = []
    (0..2).each do |row_iterator|
      (0..2).each do |col_iterator|
        if self[row_iterator + 3 * (row / 3), col_iterator + 3 * (col / 3)].is_a?(Element) && !((row_iterator + 3 * (row / 3) == row) && (col_iterator + 3 * (col / 3) == col))
          possible_for_box |= calculate_possible_numbers_for_square(row_iterator + 3 * (row / 3), col_iterator + 3 * (col / 3))
        end
      end
    end
    self[row, col].possibleNumbers - possible_for_box
  end

  def check_availability_for_square(row, col)
    # Creates a array of three result lists.
    relative_possibilities = [check_row_availability_for_square(row, col),
                              check_col_availability_for_square(row, col),
                              check_box_availability_for_square(row, col)]

    # If any of the three arrays only have one number
    relative_possibilities.each do |possible_number| 
      if possible_number && (possible_number.count == 1)
        self[row, col].relativeNumbers = possible_number
      end
    end
    self[row, col].relativeNumbers
  end

  def check_availability_for_each_square
    @solved = TRUE
    SudokuUtils.LoopPuzzle do |row, col|
      check_availability_for_square(row, col) if self[row, col].is_a? Element
    end
  end

  #------------------------------------Insertion Methods-------------------------------------

  def insert_number_into_blank(row, col, number)
    puts "Inserting #{number} into (#{row + 1},#{col + 1})" # Added 1 for more natural human coordinates
    self[row, col] = number
    @stuck, @solved = FALSE
  end

  ##
  # This method first checks the possible numbers, then the relative numbers.
  # If either is 1, then insert a number into that square.
  def insert_number_into_each_blank
    SudokuUtils.LoopPuzzle do |row, col|
      if self[row, col].is_a? Element
        if self[row, col].possibleNumbers.count == 1
          insert_number_into_blank(row, col, self[row, col].possibleNumbers[0])
        elsif self[row, col].relativeNumbers.count == 1
          insert_number_into_blank(row, col, self[row, col].relativeNumbers[0])
        end
      end
    end
  end

  def solve_puzzle
    until @solved
      calculate_possible_numbers_for_each_square
      insert_number_into_each_blank
      if @stuck
        check_availability_for_each_square
        insert_number_into_each_blank
      end
      SudokuUtils.print_readable(self)
    end
  end
end

# Each blank sudoku square will be filled with an element containing potential
# values. As well as a display character telling the print method what to show.
Element = Struct.new(:possibleNumbers, :relativeNumbers) do
  def to_s
    '.'
  end
end
