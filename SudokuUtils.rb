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

	#Found myself looping through the whole puzzle so made this helper method.
	def self.LoopPuzzle(&block)
		for row in 0..8
			for col in 0..8
				block.call(row,col)
			end
		end
	end
end

