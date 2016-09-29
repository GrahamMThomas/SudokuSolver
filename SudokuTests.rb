require 'minitest/autorun'
require_relative 'SudokuClass'
require_relative 'SudokuUtils'

class SudokuTest < Minitest::Test
	@@puzzle = Sudoku.zero(9)
	@@puzzle.LoadMatrixFromFile('SudokuDefault.txt')
	@@hardPuzzle = Sudoku.zero(9)
	@@hardPuzzle.LoadMatrixFromFile('SudokuHard1.txt')

	# def test_<MethodName>_<StateUnderTest>_<ExpectedBehavior>
	# 	methodOutput = <MethodTest>
	# 	methodExpected = <ExpectedOutput>
	# 	assert (methodOutput == methodExpected) , 
	# 	("Did not return expected numbers.\nExpected:#{methodExpected}\nGot:#{methodOutput}")
	# end

	def test_AvailableNumbersInRowOrCol_RowValid_Success
		methodOutput = @@puzzle.AvailableNumbersInRowOrCol { |i,arr| arr.push(@@puzzle[0,i].to_s) } 
		methodExpected = ['3','4','5','8','9']
		assert (methodOutput == methodExpected) , 
		("Did not return expected numbers.\nExpected:#{methodExpected}\nGot:#{methodOutput}")
	end

	def test_AvailableNumbersInRowOrCol_ColValid_Success
		methodOutput = @@puzzle.AvailableNumbersInRowOrCol { |i,arr| arr.push(@@puzzle[i,0].to_s) }
		methodExpected = ['2','3','4','5','9']
		assert (methodOutput == methodExpected) , 
		("Did not return expected numbers.\nExpected:#{methodExpected}\nGot:#{methodOutput}")
	end

	def test_AvailableNumbersInBox_Valid_Success
		methodOutput = @@puzzle.AvailableNumbersInBox(0,0)
		methodExpected = ['2','3','4','5','7']
		assert (methodOutput == methodExpected) , 
		("Did not return expected numbers.\nExpected:#{methodExpected}\nGot:#{methodOutput}")
	end

	def test_CalculatePossibleNumbersForSquare_Valid_Success
		methodOutput = @@puzzle.CalculatePossibleNumbersForSquare(0,0)
		methodExpected = ['3','4','5']
		assert (methodOutput == methodExpected) , 
		("Did not return expected numbers.\nExpected:#{methodExpected}\nGot:#{methodOutput}")
	end

	def test_CheckRowAvailabilityForSquare_Valid_Success
		@@hardPuzzle.CalculatePossibleNumbersForSquare(0,8)
		methodOutput = @@hardPuzzle.CheckRowAvailabilityForSquare(0,8)
		methodExpected = ['3']
		assert (methodOutput == methodExpected) , 
		("Did not return expected numbers.\nExpected:#{methodExpected}\nGot:#{methodOutput}")
	end

	def test_CheckColAvailabilityForSquare_Valid_Success
		@@hardPuzzle.CalculatePossibleNumbersForSquare(0,8)
		methodOutput = @@hardPuzzle.CheckColAvailabilityForSquare(0,8)
		methodExpected = ['3']
		assert (methodOutput == methodExpected) , 
		("Did not return expected numbers.\nExpected:#{methodExpected}\nGot:#{methodOutput}")
	end

	def test_CheckBoxAvailabilityForSquare_Valid_Success
		@@hardPuzzle.CalculatePossibleNumbersForSquare(0,8)
		methodOutput = @@hardPuzzle.CheckBoxAvailabilityForSquare(0,8)
		methodExpected = ['3']
		assert (methodOutput == methodExpected) , 
		("Did not return expected numbers.\nExpected:#{methodExpected}\nGot:#{methodOutput}")
	end

	def test_CheckAvailabilityForSquare_Valid_Success
		@@hardPuzzle.CalculatePossibleNumbersForSquare(0,8)
		methodOutput = @@hardPuzzle.CheckAvailabilityForSquare(0,8)
		methodExpected = ['3']
		assert (methodOutput == methodExpected) , 
		("Did not return expected numbers.\nExpected:#{methodExpected}\nGot:#{methodOutput}")
	end

	def test_InsertNumberIntoBlank_Valid_Success
		defaultPuzzle = Sudoku.zero(9).LoadMatrixFromFile('SudokuDefault.txt')
		methodOutput = defaultPuzzle.InsertNumberIntoBlank(0,0,0)
		methodExpected = 0
		assert (defaultPuzzle[0,0] == methodExpected) , 
		("Did not return expected numbers.\nExpected:#{methodExpected}\nGot:#{defaultPuzzle[0,0]}")
	end

	def test_InsertNumberIntoEachBlank_Valid_Success
		defaultPuzzle = Sudoku.zero(9).LoadMatrixFromFile('SudokuDefault.txt')
		defaultPuzzle.CalculatePossibleNumbersForEachSquare
		methodOutput = defaultPuzzle.InsertNumberIntoEachBlank
		methodExpected = '3'
		assert (defaultPuzzle[0,1] == methodExpected) , 
		("Did not return expected numbers.\nExpected:#{methodExpected}\nGot:#{defaultPuzzle[0,1]}")
	end



end