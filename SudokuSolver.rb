#Sudoku Solver
require 'matrix'

$solved = FALSE
$stuck = FALSE
#Default Matrix if user does not specify one
puzzle = Matrix[
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


class Matrix
	@@allPossibleNumbers = ['1','2','3','4','5','6','7','8','9']

	def LoadMatrixFromFile(filename)
		fileContents = OpenFile(filename)
		for row in 0..8
			for col in 0..8
				self[row,col] = fileContents[0]
				fileContents[0] = ''
			end
		end
	end

	#Prints the Matrix is a human readable format
	def PrintReadable
		print '| --------Puzzle--------'
		i = 0
		self.each do |number|
			print "|\n" if i % 9 == 0
			print "| " if i % 3 == 0
			print "#{'-'*21} |\n| " if i % 27 == 0 and i != 0
			print number.to_s + " "
			i += 1
		end
		puts "|\n| ----------------------|\n\n"
	end

	#Create an Element object in every blank square
	def InitializeBlanks
		i = 0
		self.each_with_index do |blankSpace, row, col|
			if blankSpace == '-'
				blankSpace = Element.new
				blankSpace.relativeNumbers = []
				self[row,col] = blankSpace
			end
		end
	end



#-----------------------------Simple Available Number Methods------------------------------
	#Returns all numbers not present in row of the square passed as a parameter
	def AvailableNumbersInRow(row,col)
		allActualNumbers = []
		for i in 0..9
			allActualNumbers.push(self[row,i].to_s)
		end
		#allActualNumbers.each {|num| print "#{num}, "}
		@@allPossibleNumbers - allActualNumbers
	end

	#Returns all numbers not present in row of the square passed as a parameter
	def AvailableNumbersInCol(row,col)
		allActualNumbers = []
		for i in 0..9
			allActualNumbers.push(self[i,col].to_s)
		end
		#allActualNumbers.each {|num| print "#{num}"}
		@@allPossibleNumbers - allActualNumbers
	end

	#Returns all numbers not present in box of the square passed as a parameter
	def AvailableNumbersInBox(row,col)
		allActualNumbers = []
		@@BoxRow = row/3
		@@BoxCol = col/3	
		for rowIterator in 0..2
			for colIterator in 0..2
				allActualNumbers.push(self[rowIterator+3*@@BoxRow, colIterator+3*@@BoxCol].to_s)
			end
		end
		@@allPossibleNumbers - allActualNumbers
	end


#-----------------------------Calculate Potential Numbers----------------------------------	

	#This method will combine all three methods for available numbers and will 
	# => return only numbers in all 3 outputs
	def CalculatePossibleNumbersForSquare(row,col)
		numbersAvailableForSquare = self.AvailableNumbersInRow(row,col) & 
									self.AvailableNumbersInCol(row,col) & 
									self.AvailableNumbersInBox(row,col)
		numbersAvailableForSquare
	end

	def CalculatePossibleNumbersForEachSquare()
		for row in 0..8
			for col in 0..8
				if self[row,col].is_a? Element
					self[row,col].possibleNumbers = self.CalculatePossibleNumbersForSquare(row,col)
				end
			end
		end
	end


#---------------------------Check For Whole Row Availability------------------------------
#       These Methods will determine if you can isolate a value by looking and the lanes around it.

	def CheckRowAvailabilityForSquare(row,col)
		possibilitiesForRow = []
		for i in 0..8
			if self[row,i].is_a? Element and i != col
				possibilitiesForRow = possibilitiesForRow | self.CalculatePossibleNumbersForSquare(row,i)
			end
		end
		self[row,col].possibleNumbers - possibilitiesForRow
	end

	def CheckColAvailabilityForSquare(row,col)
		possibilitiesForCol = []
		for i in 0..8
			if self[i,col].is_a? Element and i != row
				possibilitiesForCol = possibilitiesForCol | self.CalculatePossibleNumbersForSquare(i,col)
			end
		end
		self[row,col].possibleNumbers - possibilitiesForCol
	end

	def CheckBoxAvailabilityForSquare(row,col)
		possibilitiesForBox = []
		@@BoxRow = row/3
		@@BoxCol = col/3	
		for rowIterator in 0..2
			for colIterator in 0..2
				if self[rowIterator+3*@@BoxRow, colIterator+3*@@BoxCol].is_a? Element and not
							(rowIterator+3*@@BoxRow == row and colIterator+3*@@BoxCol == col)
					possibilitiesForBox = possibilitiesForBox | self.CalculatePossibleNumbersForSquare(rowIterator+3*@@BoxRow, colIterator+3*@@BoxCol)
					if row == 2 and col == 6
					end
				end
			end
		end
		self[row,col].possibleNumbers - possibilitiesForBox
	end

	def CheckAvailabilityForSquare(row,col)
		relativePossibilities = [CheckRowAvailabilityForSquare(row,col),
						 		CheckColAvailabilityForSquare(row,col),
						 		CheckBoxAvailabilityForSquare(row,col)]
		for possNumber in relativePossibilities
			if possNumber.count == 1
				$solved = FALSE
				self[row,col].relativeNumbers = possNumber
			end
		end

	end

	def CheckAvailabilityForEachSquare()
		$solved = TRUE
		for row in 0..8
			for col in 0..8
				if self[row,col].is_a? Element
					self.CheckAvailabilityForSquare(row,col)
				end
			end
		end
	end



#------------------------------------Insertion Methods-------------------------------------

	def InsertNumberIntoBlank(row,col,number)
		puts "Inserting #{number} into (#{row+1},#{col+1})" #Added 1 for more natural coordinates
		self[row,col] = number
		$stuck = FALSE
	end

	def InsertNumberIntoEachBlank()
		for row in 0..8
			for col in 0..8
				if self[row,col].is_a? Element
					self.InsertNumberIntoBlank(row,col,self[row,col].possibleNumbers[0]) if self[row,col].possibleNumbers.count == 1
					self.InsertNumberIntoBlank(row,col,self[row,col].relativeNumbers[0]) if self[row,col].relativeNumbers.count == 1
				end
			end
		end
	end


end


#Each blank sudoku square will be filled with an element containing potential
# => values. As well as a display character telling the print method what to show.
class Element
	attr_accessor :possibleNumbers
	attr_accessor :relativeNumbers

	@@displayCharacter = '.'

	def to_s
		@@displayCharacter
	end

end

#Opens a file and creates a long string containing the characters
def OpenFile(filename)
	fileContents = ''
	File.open(filename, "r") do |f|
		f.each_line do |line|
			fileContents += line.chomp
		end
	end
	fileContents
end



#User Prompts
userSelection = 0
until ['1','2','3'].include? userSelection
	puts "1: Default Puzzle\n2: Insert filename containing puzzle"
	userSelection = gets.chomp
end

if userSelection #= '2'
	puts "Enter Filename"
	userFileName = "SudokuHard1.txt"#gets.chomp
	puzzle.LoadMatrixFromFile(userFileName)
elsif userSelection != '1'
	exit
end

#Setup
puzzle.InitializeBlanks()
puzzle.PrintReadable()

#-----------MAIN
#Loop Continuously until no more spaces contain an 'Element'
until $solved
	$stuck = TRUE
	puzzle.CalculatePossibleNumbersForEachSquare
	puzzle.InsertNumberIntoEachBlank
	if $stuck
		puzzle.CheckAvailabilityForEachSquare
		puzzle.InsertNumberIntoEachBlank
	end
	puzzle.PrintReadable
end
