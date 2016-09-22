#Sudoku Solver
require 'matrix'

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

	def loadMatrixFromFile(filename)
		fileContents = OpenFile(filename)
		for x in 0..8
			for y in 0..8
				self[x,y] = fileContents[0]
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
		self.each_with_index do |blankSpace, x, y|
			if blankSpace == '-'
				blankSpace = Element
				self[x,y] = blankSpace
			end
		end
	end

	#Returns all numbers not present in row of the square passed as a parameter
	def AvailableNumbersInRow(x,y)
		allActualNumbers = []
		for i in 0..9
			allActualNumbers.push(self[x,i].to_s)
		end
		#allActualNumbers.each {|num| print "#{num}, "}
		@@allPossibleNumbers - allActualNumbers
	end

	#Returns all numbers not present in row of the square passed as a parameter
	def AvailableNumbersInCol(x,y)
		allActualNumbers = []
		for i in 0..9
			allActualNumbers.push(self[i,y].to_s)
		end
		#allActualNumbers.each {|num| print "#{num}"}
		@@allPossibleNumbers - allActualNumbers
	end

	#Returns all numbers not present in box of the square passed as a parameter
	def AvailableNumbersInBox(x,y)
		allActualNumbers = []
		@BoxX = x/3
		@BoxY = y/3	
		for xIterator in 0..2
			for yIterator in 0..2
				#puts "Checking: #{xIterator+3*@BoxX},#{yIterator+3*@BoxY}"
				allActualNumbers.push(self[xIterator+3*@BoxX, yIterator+3*@BoxY].to_s)
			end
		end
		@@allPossibleNumbers - allActualNumbers
	end

	#This method will combine all three methods for available numbers and will 
	# => return only numbers in all 3 outputs
	def CalculatePossibleNumbersForSquare(x,y)
		numbersAvailableForSquare = self.AvailableNumbersInRow(x,y) & 
									self.AvailableNumbersInCol(x,y) & 
									self.AvailableNumbersInBox(x,y)
		self.InsertNumberIntoBlank(x,y,numbersAvailableForSquare[0]) if numbersAvailableForSquare.count == 1
		numbersAvailableForSquare
	end

	def InsertNumberIntoBlank(x,y,number)
		puts "Inserting #{number} into (#{x+1},#{y+1})" #Added 1 for more natural coordinates
		self[x,y] = number
	end
end


#Each blank sudoku square will be filled with an element containing potential
# => values. As well as a display character telling the print method what to show.
class Element
	@@possibleNumbers = []
	@@displayCharacter = '.'
	def self.possibleNumbers
		@@possibleNumbers
	end
	def self.to_s
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

if userSelection == '2'
	puts "Enter Filename"
	userFileName = gets.chomp
	puzzle.loadMatrixFromFile(userFileName)
elsif userSelection != '1'
	exit
end

#Setup
puzzle.InitializeBlanks()
puzzle.PrintReadable()

#Loop Continuously until no more spaces contain an 'Element'
solved = FALSE
until solved
	solved = TRUE
	for x in 0..8
		for y in 0..8
			if puzzle[x,y].is_a? Class
				solved = FALSE
				puzzle.CalculatePossibleNumbersForSquare(x,y)
			end
		end
	end
	puzzle.PrintReadable
end
