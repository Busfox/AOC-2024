require 'pry'

word_search = ARGF.map { |line| line.split.first.chars }

class Part1
  attr_reader :word_search
  attr_accessor :xmas_count

  def initialize(input)
    @word_search = input
    @xmas_count = 0
    @target_depth = 4
  end

  def solve
    puts "Part 1"
    puts "--------"
    @word_search.each_with_index do |row, row_index|
      row.each_with_index do |column_value, column_index|
        next unless x_or_s?(column_value)
        direction = is_x?(column_value) ? 'forward' : 'backward'

        find_xmas(column_value, row_index, column_index, direction)
        find_xmas(column_value, row_index, column_index, direction, horizontal: false)
        find_xmas(column_value, row_index, column_index, direction, horizontal: false, diagonal: true)
        find_xmas(column_value, row_index, column_index, direction, horizontal: false, diagonal: true, reverse_diagonal: true)
      end
      puts "Found #{xmas_count} so far (row #{row_index})"
    end
    puts " "
  end

  def x_or_s?(char)
    is_s?(char) ||
    is_x?(char)
  end

  def is_s?(char)
    'S' == char&.upcase
  end

  def is_x?(char)
    'X' == char&.upcase
  end

  def is_m?(char)
    'M' == char&.upcase
  end

  def is_a?(char)
    'A' == char&.upcase
  end

  def found_next_letter?(target, origin, direction)
    case direction
    when 'forward'
      (is_x?(origin) && is_m?(target)) ||
      (is_m?(origin) && is_a?(target)) ||
      (is_a?(origin) && is_s?(target))
    when 'backward'
      (is_s?(origin) && is_a?(target)) ||
      (is_a?(origin) && is_m?(target)) ||
      (is_m?(origin) && is_x?(target))
    end
  end

  def find_xmas(origin, row_index, column_index, depth = 1, direction, horizontal: true, diagonal: false, reverse_diagonal: false)
    return false if (@word_search[row_index + 1]).nil? && !horizontal
    return false if diagonal && reverse_diagonal && column_index == 0

    target_row_index = horizontal ? row_index : (row_index + 1)
    target_column_index = determine_target_column_index(horizontal, diagonal, reverse_diagonal, row_index, column_index)
    target = @word_search[target_row_index][target_column_index]

    return false if target.nil?
    return false unless found_next_letter?(target, origin, direction)

    depth += 1

    if depth == @target_depth
      @xmas_count += 1
      return true
    end

    find_xmas(target, target_row_index, target_column_index, depth, direction, horizontal:, diagonal:, reverse_diagonal:)
  end

  def determine_target_column_index(horizontal, diagonal, reverse_diagonal, row_index, column_index)
    if !diagonal
      horizontal ? (column_index + 1) : column_index
    else
      sign = reverse_diagonal ? :- : :+
      column_index.send(sign, 1)
    end
  end
end

class Part2 < Part1
  def initialize(input)
    super
    @target_depth = 3
    @x_mas_count = 0
  end

  def solve
    puts "Part 2"
    puts "--------"
    @word_search.each_with_index do |row, row_index|
      row.each_with_index do |column_value, column_index|
        next unless m_or_s?(column_value)

        direction = is_m?(column_value) ? 'forward' : 'backward'
        diagonal = find_xmas(column_value, row_index, column_index, direction, horizontal: false, diagonal: true)

        new_column_value = row[column_index + 2]
        direction = is_m?(new_column_value) ? 'forward' : 'backward'
        reverse_diagonal = find_xmas(new_column_value, row_index, column_index + 2, direction, horizontal: false, diagonal: true, reverse_diagonal: true)

        if diagonal && reverse_diagonal
          @x_mas_count += 1
        end
      end
      puts "Found #{@x_mas_count} so far (row #{row_index})"

    end
  end

  def m_or_s?(char)
    is_s?(char) ||
    is_m?(char)
  end

  def found_next_letter?(target, origin, direction)
    case direction
    when 'forward'
      (is_m?(origin) && is_a?(target)) ||
      (is_a?(origin) && is_s?(target))
    when 'backward'
      (is_s?(origin) && is_a?(target)) ||
      (is_a?(origin) && is_m?(target))
    end
  end
end

part1 = Part1.new(word_search)
part1.solve

part2 = Part2.new(word_search)
part2.solve