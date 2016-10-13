# Sudoku Solver
require_relative 'sudoku_class'

#--------------User Prompts--------------
puts '#################################'
puts '#         Sudoku Solver         #'
puts '#            by: Jax            #'
puts '#################################'

puzzle = Sudoku.zero(9)
user_selection = 0

until ['1','2'].include? user_selection
  puts "1: Default Puzzle\n2: Insert filename containing puzzle"
  user_selection = gets.chomp
end

case user_selection
when '1'
  puts 'Running Default Puzzle'
  puzzle.load_matrix_from_file('Puzzles/SudokuDefault.txt')
when '2'
  puts 'Enter Filename'
  user_file_name = gets.chomp
  puzzle.load_matrix_from_file(user_file_name)
else
  exit
end

SudokuUtils.print_readable(puzzle)

puzzle.Solve
