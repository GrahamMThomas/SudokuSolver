#Sudoku Solver
require 'matrix'

#Stuck is a variable which turns to true with there are no more easy insertions to be made.
$stuck = FALSE

#Solved is set to true when the advanced logic can no longer insert any numbers.
$solved = FALSE

module SudokuUtils
	#Opens a file and creates a long string containing the characters
	def self.OpenFile(filename)
		fileContents = ''
		begin
			File.open(filename, "r") do |f|
				f.each_line do |line|
					fileContents += line.chomp
				end
			end
		rescue
			puts "[ERROR] Could not read file"
			exit
		end
		fileContents
	end

	#Prints the Matrix is a human readable format
	def self.PrintReadable(puzzle)
		print '| --------Puzzle--------'
		i = 0
		puzzle.each do |number|
			print "|\n" if i % 9 == 0
			print "| " if i % 3 == 0
			print "#{'-'*21} |\n| " if i % 27 == 0 and i != 0
			print number.to_s + " "
			i += 1
		end
		puts "|\n| ----------------------|\n\n"
	end

	def self.LoopPuzzle(&block)
		for row in 0..8
			for col in 0..8
				block.call(row,col)
			end
		end
	end

end

class Sudoku < Matrix
	@@allPossibleNumbers = ['1','2','3','4','5','6','7','8','9']

	#Loads a string from a file and creates a matrix.
	def LoadMatrixFromFile(filename)
		fileContents = SudokuUtils.OpenFile(filename)
		SudokuUtils.LoopPuzzle do |row,col|
			self[row,col] = fileContents[0]
			fileContents[0] = ''
		end
		self.InitializeBlanks
	end

	#Create an Element object in every blank square
	def InitializeBlanks
		self.each_with_index do |blankSpace, row, col|
			if blankSpace == '-'
				blankSpace = Element.new
				blankSpace.relativeNumbers = []
				self[row,col] = blankSpace
			end
		end
	end



#-----------------------------Simple Available Number Methods------------------------------
#These methods simply find the numbers that are not located in a row, column, or box

	#This method takes a block which will push the row or column into an array.
	def AvailableNumbersInRowOrCol(&block)
		allActualNumbers = []
		for i in 0..9
			block.call(i,allActualNumbers)
		end
		@@allPossibleNumbers - allActualNumbers
	end

	#Returns all numbers not present in box of the square passed as a parameter
	def AvailableNumbersInBox(row,col)
		allActualNumbers = []
		for rowIterator in 0..2
			for colIterator in 0..2
				allActualNumbers.push(self[rowIterator+3*(row/3), colIterator+3*(col/3)].to_s)
			end
		end
		@@allPossibleNumbers - allActualNumbers
	end


#-----------------------------Calculate Potential Numbers----------------------------------	

	##
	#This method will combine all three methods for available numbers and will 
	#return only numbers in all 3 outputs
	def CalculatePossibleNumbersForSquare(row,col)
		numbersAvailableForSquare = self.AvailableNumbersInBox(row,col) & 
									self.AvailableNumbersInRowOrCol { |i,arr| arr.push(self[row,i].to_s) } &
									self.AvailableNumbersInRowOrCol { |i,arr| arr.push(self[i,col].to_s) }
	end

	#Loops through puzzle and run a method all all of the elements.
	def CalculatePossibleNumbersForEachSquare()
		$stuck = TRUE
		SudokuUtils.LoopPuzzle do |row, col|
			if self[row,col].is_a? Element
				self[row,col].possibleNumbers = self.CalculatePossibleNumbersForSquare(row,col)
			end
		end
	end


#---------------------------Check For Square Availability Based on Surrounding Squares------------------------------
#These Methods will check to see if you can determine the value for a square by looking at the lanes around it.

	#Checks row to see if this square is the only square that can be a number.
	def CheckRowAvailabilityForSquare(row,col)
		possibilitiesForRow = []
		for i in 0..8
			if self[row,i].is_a? Element and i != col
				possibilitiesForRow = possibilitiesForRow | self.CalculatePossibleNumbersForSquare(row,i)
			end
		end
		self[row,col].possibleNumbers - possibilitiesForRow
	end

	#Checks column to see if this square is the only square that can be a number.
	def CheckColAvailabilityForSquare(row,col)
		possibilitiesForCol = []
		for i in 0..8
			if self[i,col].is_a? Element and i != row
				possibilitiesForCol = possibilitiesForCol | self.CalculatePossibleNumbersForSquare(i,col)
			end
		end
		self[row,col].possibleNumbers - possibilitiesForCol
	end

	#Checks box to see if this square is the only square that can be a number.
	def CheckBoxAvailabilityForSquare(row,col)
		possibilitiesForBox = []
		for rowIterator in 0..2
			for colIterator in 0..2
				if self[rowIterator+3*(row/3), colIterator+3*(col/3)].is_a? Element and not
					   (rowIterator+3*(row/3) == row and colIterator+3*(col/3) == col)
					possibilitiesForBox = possibilitiesForBox | self.CalculatePossibleNumbersForSquare(rowIterator+3*(row/3), colIterator+3*(col/3))
				end
			end
		end
		self[row,col].possibleNumbers - possibilitiesForBox
	end


	def CheckAvailabilityForSquare(row,col)
		#Creates a array of three result lists.
		relativePossibilities = [CheckRowAvailabilityForSquare(row,col),
						 		CheckColAvailabilityForSquare(row,col),
						 		CheckBoxAvailabilityForSquare(row,col)]
		relativePossibilities.each do |possNumber| #If any of the three arrays only have one number
			if possNumber.count == 1
				self[row,col].relativeNumbers = possNumber
			end
		end

	end

	def CheckAvailabilityForEachSquare()
		$solved = TRUE
		SudokuUtils.LoopPuzzle do |row,col|
			self.CheckAvailabilityForSquare(row,col) if self[row,col].is_a? Element
		end
	end



#------------------------------------Insertion Methods-------------------------------------

	def InsertNumberIntoBlank(row,col,number)
		puts "Inserting #{number} into (#{row+1},#{col+1})" #Added 1 for more natural human coordinates
		self[row,col] = number
		$stuck,$solved = FALSE
	end

	##
	#This method first checks the possible numbers, then the relative numbers.
	#If either is 1, then insert a number into that square.
	def InsertNumberIntoEachBlank()
		SudokuUtils.LoopPuzzle do |row, col|
			if self[row,col].is_a? Element
				if self[row,col].possibleNumbers.count == 1
					self.InsertNumberIntoBlank(row,col,self[row,col].possibleNumbers[0]) 
				elsif self[row,col].relativeNumbers.count == 1
					self.InsertNumberIntoBlank(row,col,self[row,col].relativeNumbers[0])
				end
			end
		end
	end


end


#Each blank sudoku square will be filled with an element containing potential
#values. As well as a display character telling the print method what to show.
Element = Struct.new(:possibleNumbers, :relativeNumbers) do
	def to_s
		"."
	end
end


#Default Matrix if user does not specify one
puzzle = Sudoku[
	['-', '-', '-', '2', '6', '-', '7', '-', '1'],
	['6', '8', '-', '-', '7', '-', '-', '9', '-'],
	['1', '9', '-', '-', '-', '4', '5', '-', '-'],
	['8', '2', '-', '1', '-', '-', '-', '4', '-'],
	['-', '-', '4', '6', '-', '2', '9', '-', '-'],
	['-', '5', '-', '-', '-', '3', '-', '2', '8'],
	['-', '-', '9', '3', '-', '-', '-', '7', '4'],
	['-', '4', '-', '-', '5', '-', '-', '3', '6'],
	['7', '-', '3', '-', '1', '8', '-', '-', '-']
]
puzzle.InitializeBlanks()


#User Prompts
userSelection = 0
until ['1','2','3'].include? userSelection
	puts "1: Default Puzzle\n2: Insert filename containing puzzle"
	userSelection = gets.chomp
end

if userSelection == '2'
	puts "Enter Filename"
	userFileName = gets.chomp
	puzzle.LoadMatrixFromFile(userFileName)
elsif userSelection != '1'
	exit
end

#Setup
SudokuUtils.PrintReadable(puzzle)

#-----------MAIN
#Loop Continuously until no more spaces contain an 'Element'
until $solved
	puzzle.CalculatePossibleNumbersForEachSquare
	puzzle.InsertNumberIntoEachBlank
	if $stuck
		puzzle.CheckAvailabilityForEachSquare
		puzzle.InsertNumberIntoEachBlank
	end
	SudokuUtils.PrintReadable(puzzle)
end
