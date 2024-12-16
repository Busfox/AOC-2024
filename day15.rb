require 'pry'

map, movements = ARGF.read.split("\n\n")

class Part1
  def initialize(map, movements)
    @map = map.split("\n").map(&:chars)
    @movements = movements.chars.reject! {|x| x == "\n"}
    @robot_position = nil
    set_robot_starting_position
    @current_line = []
  end

  def solve
    @movements.each do |movement|
      @current_line.clear
      step = determine_step(movement)
      find_next_wall(@robot_position, step)
      next if @current_line.empty?
      next unless @current_line.any? { |coords| @map[coords.first][coords.last] == '.' }

      positions_to_move = @current_line.take_while.with_index do |coordinate, index|
        @map[coordinate.first][coordinate.last] != '.'
      end

      positions_to_move += [@current_line.find { |elem| @map[elem.first][elem.last] == '.' }]

      positions_to_move.insert(0, @robot_position)

      positions_to_move.reverse.each_cons(2) do |coordinate, new_coordinate|
        next if coordinate.nil?
        @map[coordinate.first][coordinate.last] = @map[new_coordinate.first][new_coordinate.last]
      end

      @map[positions_to_move.first.first][positions_to_move.first.last] = '.'
      @robot_position = positions_to_move[1]
    end

    box_coordinates_sum
  end

  def find_next_wall(start_position, step)

    line_position = [start_position, step].transpose.map(&:sum)
    return if wall?(@map[line_position.first][line_position.last])

    @current_line << line_position
    find_next_wall(line_position, step)
  end

  def set_robot_starting_position
    @map.each_with_index do |line, row_index|
      line.each_with_index do |char, column_index|
        @robot_position = [row_index, column_index] if char == '@'
      end
    end
  end

  def determine_step(movement)
    case movement
    when '>'
      [0, 1]
    when '<'
      [0, -1]
    when 'v'
      [1, 0]
    when '^'
      [-1, 0]
    else
      binding.pry
    end
  end

  def wall?(value)
    value == '#'
  end

  def box_coordinates_sum
    sum = 0
    @map.each_with_index do |line, row_index|
      line.each_with_index do |char, column_index|
        sum += (row_index * 100 + column_index) if char == 'O'
      end
    end
    sum
  end
end

part1 = Part1.new(map, movements)
puts part1.solve

# part2 = Part2.new(input)
# puts part2.solve