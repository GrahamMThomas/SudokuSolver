#Sudoku Solver
require_relative 'SudokuClass'

#--------------User Prompts--------------
puts "#################################"
puts "#         Sudoku Solver         #"
puts "#            by: Jax            #"
puts "#################################"

puzzle = Sudoku.zero(9)
userSelection = 0

until ['1','2'].include? userSelection
	puts "1: Default Puzzle\n2: Insert filename containing puzzle"
	userSelection = gets.chomp
end

case userSelection
when '1'
	puts "Running Default Puzzle"
	puzzle.LoadMatrixFromFile('Puzzles/SudokuDefault.txt')
when '2'
	puts "Enter Filename"
	userFileName = gets.chomp
	puzzle.LoadMatrixFromFile(userFileName)
else
	exit
end

SudokuUtils.PrintReadable(puzzle)

puzzle.Solve
