module SudokuUtils
  # Opens a file and creates a long string containing the characters
  def self.open_file(filename)
    file_contents = ''
    begin
    File.open(filename, 'r') do |f|
      f.each_line do |line|
        file_contents += line.chomp
      end
    end
  rescue
    puts '[ERROR] Could not read file'
    exit
  end
    if file_contents.length != 81
      puts 'Not a sudoku puzzle. Character count not equal 81.'
      exit
    end
    file_contents
  end

  # Prints the Matrix is a human readable format
  def self.print_readable(puzzle)
    print '| --------Puzzle--------'
    i = 0
    puzzle.each do |number|
      print "|\n" if (i % 9).zero?
      print '| ' if (i % 3).zero?
      print "#{'-' * 21} |\n| " if (i % 27).zero? && i.nonzero?
      print number.to_s + ' '
      i += 1
    end
    puts "|\n| ----------------------|\n\n"
  end

  # Found myself looping through the whole puzzle so made this helper method.
  def self.LoopPuzzle(&block)
    (0..8).each do |row|
      (0..8).each do |col|
        block.call(row, col)
      end
    end
  end
end
