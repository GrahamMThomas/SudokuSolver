require 'matrix'
require_relative 'SudokuUtils'

class Sudoku < Matrix
	#Stuck is a variable which turns to true with there are no more easy insertions to be made.
	@stuck = FALSE

	#Solved is set to true when the advanced logic can no longer insert any numbers.
	@solved = FALSE

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
				blankSpace.possibleNumbers = []
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

	##
	#This method will combine all methods for available numbers and will 
	#return only numbers in all 3 outputs
	def CalculatePossibleNumbersForSquare(row,col)
		self[row,col].possibleNumbers = self.AvailableNumbersInBox(row,col) & 
									self.AvailableNumbersInRowOrCol { |i,arr| arr.push(self[row,i].to_s) } &
									self.AvailableNumbersInRowOrCol { |i,arr| arr.push(self[i,col].to_s) }
	end

	#Loops through puzzle and run a method all all of the elements.
	def CalculatePossibleNumbersForEachSquare
		@stuck = TRUE
		SudokuUtils.LoopPuzzle do |row, col|
			if self[row,col].is_a? Element
				self.CalculatePossibleNumbersForSquare(row,col)
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
			if possNumber and possNumber.count == 1
				self[row,col].relativeNumbers = possNumber
			end
		end
		self[row,col].relativeNumbers
	end

	def CheckAvailabilityForEachSquare
		@solved = TRUE
		SudokuUtils.LoopPuzzle do |row,col|
			self.CheckAvailabilityForSquare(row,col) if self[row,col].is_a? Element
		end
	end


#------------------------------------Insertion Methods-------------------------------------

	def InsertNumberIntoBlank(row,col,number)
		puts "Inserting #{number} into (#{row+1},#{col+1})" #Added 1 for more natural human coordinates
		self[row,col] = number
		@stuck,@solved = FALSE
	end

	##
	#This method first checks the possible numbers, then the relative numbers.
	#If either is 1, then insert a number into that square.
	def InsertNumberIntoEachBlank
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

	def Solve
		until @solved
			self.CalculatePossibleNumbersForEachSquare
			self.InsertNumberIntoEachBlank
			if @stuck
				self.CheckAvailabilityForEachSquare
				self.InsertNumberIntoEachBlank
			end
			SudokuUtils.PrintReadable(self)
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