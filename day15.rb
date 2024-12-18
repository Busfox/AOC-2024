require 'pry'

map, movements = ARGF.read.split("\n\n")

class Part1
  MOVEMENT_VECTORS = {
    '>' => [0, 1],
    '<' => [0, -1],
    'v' => [1, 0],
    '^' => [-1, 0]
  }.freeze

  WALL = '#'
  ROBOT = '@'
  BOX = 'O'
  EMPTY = '.'

  def initialize(map, movements)
    @map = map.split("\n").map(&:chars)
    @movements = movements.chars.reject { |x| x == "\n" }
    @robot_position = find_robot_starting_position
  end

  def solve
    @movements.each do |movement|
      step = determine_step(movement)
      @current_line = trace_path_to_wall(@robot_position, step)

      next if @current_line.empty? || !valid_positions_in_line?

      move_robot_to_next_position
    end

    calculate_box_coordinates_sum
  end

  private

  # Finds the starting position of the robot.
  def find_robot_starting_position
    @map.each_with_index do |row, row_index|
      column_index = row.index(ROBOT)
      return [row_index, column_index] if column_index
    end
    nil
  end

  # Determines the movement vector based on the movement character.
  def determine_step(movement)
    MOVEMENT_VECTORS[movement]
  end

  # Traces the path until hitting a wall and returns the path.
  def trace_path_to_wall(start_position, step)
    path = []
    current_position = start_position

    loop do
      next_position = add_positions(current_position, step)
      break if wall?(next_position)

      path << next_position
      current_position = next_position
    end

    path
  end

  # Moves the robot to the next valid position in the path.
  def move_robot_to_next_position
    positions_to_move = @current_line.take_while do |coordinate|
      @map[coordinate.first][coordinate.last] != EMPTY
    end

    positions_to_move << @current_line.find { |coord| @map[coord.first][coord.last] == EMPTY }
    positions_to_move.compact!
    update_positions(positions_to_move)
  end

  # Updates the map with new robot positions and clears the previous position.
  def update_positions(positions)
    positions.unshift(@robot_position)

    positions.reverse.each_cons(2) do |from, to|
      @map[from.first][from.last] = @map[to.first][to.last]
    end

    @map[positions.first.first][positions.first.last] = EMPTY
    @robot_position = positions[1]
  end

  # Checks if there are valid positions to move to in the current line.
  def valid_positions_in_line?
    @current_line.any? { |coords| @map[coords.first][coords.last] == EMPTY }
  end

  # Returns whether the position contains a wall.
  def wall?(position)
    value_at(position) == WALL
  end

  # Adds two coordinate arrays together.
  def add_positions(pos1, pos2)
    [pos1.first + pos2.first, pos1.last + pos2.last]
  end

  # Safely retrieves the value at a given position on the map.
  def value_at(position)
    row, col = position
    return nil if row < 0 || col < 0 || row >= @map.size || col >= @map[row].size

    @map[row][col]
  end

  # Calculates the sum of coordinates for target boxes.
  def calculate_box_coordinates_sum
    @map.each_with_index.sum do |row, row_index|
      row.each_with_index.sum do |char, column_index|
        char == BOX ? (row_index * 100 + column_index) : 0
      end
    end
  end
end

# class Part2 < Part1
#   WALL = '#'
#   ROBOT = '@'
#   BOX = ['[',']']
#   EMPTY = '.'

#   def initialize(map, movement)
#     super

#     @map = stretch_out_map
#     @robot_position = find_robot_starting_position
#   end

#   def solve
#     @movements.each do |movement|
#       # binding.pry
#       @map.each do |m|
#         puts "#{m}"
#       end

#       step = determine_step(movement)
#       @current_line = trace_path_to_wall(@robot_position, step)
#       if @current_line.size > 1

#         line = nil
#         adjacent_lines = @current_line[:adjacent]
#         @current_line[:adjacent] = []

#         adjacent_lines.each do |adjacent|
#           map_adjacent_lines([adjacent], step)
#         end
#       end

#       next if @current_line[:standard].empty? || !valid_positions_in_line?(@current_line[:standard]) || (!@current_line[:adjacent].nil? && @current_line[:adjacent].all? { |line| !valid_positions_in_line?(line) })

#       move_robot_to_next_position(step)
#     end

#     binding.pry

#     calculate_box_coordinates_sum
#   end

#   def map_adjacent_lines(adjacent, step)
#     previous_adjacent = nil

#     loop do |i|
#       break if adjacent.nil? || !previous_adjacent.nil? && (adjacent.first.first - previous_adjacent.first.first).abs > 1

#       line = trace_path_to_wall(adjacent.first, step)
#       previous_adjacent = adjacent
#       adjacent = line[:adjacent]
#       @current_line[:adjacent] << line[:standard]
#     end
#   end

#   # Updates the map with new robot positions and clears the previous position.
#   def update_positions(positions, max, robot_should_move: true)
#     # binding.pry if !max.nil?
#     positions.reverse.each_cons(2) do |to, from|
#       puts "#{max}"
#       # binding.pry if max == {"up"=>[2]}
#       # if !max.nil? && !max['down'].nil? && max['down'] < to.first || !max.nil? && !max['up'].nil? && max['up'] > to.first
#       #   binding.pry
#       #   next
#       # end
#       @map[to.first][to.last] = @map[from.first][from.last]
#     end

#     @map[positions.first.first][positions.first.last] = EMPTY
#     @robot_position = positions[1] if robot_should_move
#   end

#   # Traces the path until hitting a wall and returns the path.
#   def trace_path_to_wall(start_position, step)
#     binding.pry if start_position == [7,10]
#     path = { standard: [] }
#     current_position = start_position

#     loop do
#       # binding.pry
#       next_position = add_positions(current_position, step)
#       # binding.pry if next_position == [2, 5]

#       break if path[:standard].size == 1 && value_at(path[:standard].first) == EMPTY

#       if step.first != 0 && box?(next_position)
#         path[:adjacent] = [] unless path[:adjacent]
#         if value_at(next_position) == BOX.first # left side of box
#           path[:adjacent] << [next_position.first, next_position.last + 1]
#           path[:adjacent] << [next_position.first, next_position.last + 2] if value_at([next_position.first, next_position.last + 2]) == EMPTY
#         elsif value_at(next_position) == BOX.last # right side of box
#           path[:adjacent] << [next_position.first, next_position.last - 1]
#           path[:adjacent] << [next_position.first, next_position.last - 2] if value_at([next_position.first, next_position.last - 2]) == EMPTY
#         end
#       end
#       break if wall?(next_position)

#       path[:standard] << next_position
#       current_position = next_position
#     end

#     path
#   end

#   def move_robot_to_next_position(step)
#     positions_to_move = @current_line[:standard].take_while do |coordinate|
#       @map[coordinate.first][coordinate.last] != EMPTY
#     end

#     max = if step == MOVEMENT_VECTORS['^'] && @current_line[:adjacent]
#       to_add = @current_line[:adjacent].any?(&:empty?) ? 1 : 0

#       foo = @current_line[:adjacent].delete_if { |elem| elem.flatten.empty? }.map { |x| x.map(&:first) }
#       binding.pry if @current_line[:adjacent].delete_if { |elem| elem.flatten.empty? }.map { |x| x.map(&:first) }.reduce(:&).first.nil?

#       { 'up' => @current_line[:adjacent].delete_if { |elem| elem.flatten.empty? }.map { |x| x.map(&:first) }.reduce(:&).first + to_add }
#     elsif step == MOVEMENT_VECTORS['v'] && @current_line[:adjacent]
#       to_sub = @current_line[:adjacent].any?(&:empty?) ? 1 : 0
#       binding.pry if @current_line[:adjacent].delete_if { |elem| elem.flatten.empty? }.map { |x| x.map(&:first) }.reduce(:&).first.nil?

#       foo = @current_line[:adjacent].delete_if { |elem| elem.flatten.empty? }.map { |x| x.map(&:first) }
#       foo.pop unless foo.map(&:first).each_cons(2).all? {|a, b| b == a + 1 }
#       { 'down' => foo.reduce(:&).first - to_sub }
#     end

#     adjacent_positions_to_move = @current_line[:adjacent].map do |line|
#       # binding.pry
#       positions = line.take_while { |coords| @map[coords.first][coords.last] != EMPTY }
#       first_empty = line.find { |coord| @map[coord.first][coord.last] == EMPTY }
#       positions << first_empty if first_empty
#       positions.insert(0, [positions.first.first - step.first, positions.first.last]) if first_empty
#     end.compact if @current_line[:adjacent]

#     positions_to_move << @current_line[:standard].find { |coord| @map[coord.first][coord.last] == EMPTY }
#     positions_to_move.compact!
#     positions_to_move.unshift(@robot_position)

#     # binding.pry if !max.nil?

#     return if !max.nil? && max['down'].nil? && adjacent_positions_to_move && ([positions_to_move] + adjacent_positions_to_move).flatten(1).map(&:first).any? {|x| x < max['up'] } ||
#     !max.nil? && max['up'].nil? && adjacent_positions_to_move && ([positions_to_move] + adjacent_positions_to_move).flatten(1).map(&:first).any? {|x| x > max['down'] }

#     update_positions(positions_to_move, max)
#     return unless adjacent_positions_to_move
#     adjacent_positions_to_move.each do |line|
#       update_positions(line, max, robot_should_move: false)
#     end
#   end

#   # Checks if there are valid positions to move to in the current line.
#   def valid_positions_in_line?(line)
#     line.any? { |coords| @map[coords.first][coords.last] == EMPTY }
#   end

#   def stretch_out_map
#     new_map = []

#     @map.each_with_index do |line, row_index|
#       new_line = []

#       line.each_with_index do |char, column_index|
#         case char
#         when '#'
#           new_line << '#'
#           new_line << '#'
#         when 'O'
#           new_line << '['
#           new_line << ']'
#         when '.'
#           new_line << '.'
#           new_line << '.'
#         when '@'
#           new_line << '@'
#           new_line << '.'
#         else
#           binding.pry
#         end
#       end

#       new_map << new_line
#     end

#     new_map
#   end

#   def calculate_box_coordinates_sum
#     @map.each_with_index.sum do |row, row_index|
#       row.each_with_index.sum do |char, column_index|
#         char == BOX.first ? (row_index * 100 + column_index) : 0
#       end
#     end
#   end

#   def box?(position)
#     BOX.include?(value_at(position))
#   end
# end


class Part2 < Part1
  WALL = '#'
  ROBOT = '@'
  BOX = ['[',']']
  EMPTY = '.'

  def initialize(map, movement)
    super

    @map = stretch_out_map
    @robot_position = find_robot_starting_position
  end

  def solve
    @movements.each do |movement|
      print_map

      step = determine_step(movement)

      can_move = can_move?(@robot_position, step)

      new_positions_and_values = get_new_positions_and_values(@robot_position, step) if can_move

      move(new_positions_and_values) unless new_positions_and_values.nil?
    end

    print_map

  end

  def print_map
    @map.each do |m|
      puts "#{m.join(' ')}"
    end
    puts "----------------------------------"
  end

  def get_new_positions_and_values(start_position, step, initial: true)
    result = nil
    original_line = new_positions_and_values_in_line(start_position, step)
    # binding.pry

    if moving_vertically?(step) && original_line.size > 2
      adjacent_boxes = original_line.map do |coords, value|
        check_for_box_connection(coords, step)
      end

      adjacent_boxes_grouped_by_column = adjacent_boxes.compact.group_by(&:last).map { |k,v| {k => v.map(&:first)} }

      foo = adjacent_boxes_grouped_by_column.map do |group|
        # binding.pry
        column = group.keys.first
        row = MOVEMENT_VECTORS['v'] == step ? group.values.first.min : group.values.first.max
        next if column == start_position.last
        # binding.pry
        new_positions_and_values_in_line([row, column], step, original_line: false)
      end
      # binding.pry

      done = check_if_all_boxes_are_complete(foo, original_line)

      binding.pry if !done

      if done
        result = foo.map do |line|
          original_line.merge(line)
        end.first

        return result
      end
    end

    original_line
  end

  def check_if_all_boxes_are_complete(adjacent_lines, original_line)
    results = []
    adjacent_lines.each do |line|
      line.each do |coords, value|
        next unless BOX.include?(value)

        if value == ']' && (original_line[[coords.first, coords.last - 1]] == BOX.first || original_line[[coords.first, coords.last + 1]] == BOX.first)
          results << true
        elsif value == '[' && (original_line[[coords.first, coords.last - 1]] == BOX.last || original_line[[coords.first, coords.last + 1]] == BOX.last)
          results << true
        else
          results << false
        end
      end
    end

    !results.include?(false)
  end

  def check_for_box_connection(position, step)
    if box?(position) && moving_vertically?(step)
      if left_box?(position)
        [position.first, position.last + 1]
      elsif right_box?(position)
        [position.first, position.last - 1]
      end
    end
  end

  def new_positions_and_values_in_line(start_position, step, initial: true, original_line: true)
    result = {}
    new_position = add_positions(start_position, step)
    result[new_position] = value_at(start_position)
    result[start_position] = '.' if initial
    return result if empty?(new_position)

    if box?(new_position)
      recusive_result = new_positions_and_values_in_line(new_position, step, initial:false, original_line:)
      result.merge!(recusive_result)
    end

    result
  end

  def move(new_positions_and_values)
    new_positions_and_values.each do |position, value|
      @map[position.first][position.last] = value
      @robot_position = position if value == '@'
    end
  end

  def can_move?(start_position, step)
    new_position = add_positions(start_position, step)
    return false if wall?(new_position)
    return true if empty?(new_position)

    new_start_positions_to_check = [new_position]

    if box?(new_position) && moving_vertically?(step)
      if left_box?(new_position)
        new_start_positions_to_check << [new_position.first, new_position.last + 1]
      elsif right_box?(new_position)
        new_start_positions_to_check << [new_position.first, new_position.last - 1]
      end
    end

    results = new_start_positions_to_check.map do |new_start_position|
      can_move?(new_start_position, step)
    end

    return true if results.all? { |result| result == true }

    false
  end

  def moving_vertically?(step)
    !step.first.zero?
  end

  def box?(position)
    BOX.include?(value_at(position))
  end

  def empty?(position)
    value_at(position) == EMPTY
  end

  def left_box?(position)
    value_at(position) == BOX.first
  end

  def right_box?(position)
    value_at(position) == BOX.last
  end

  def stretch_out_map
    new_map = []

    @map.each_with_index do |line, row_index|
      new_line = []

      line.each_with_index do |char, column_index|
        case char
        when '#'
          new_line << '#'
          new_line << '#'
        when 'O'
          new_line << '['
          new_line << ']'
        when '.'
          new_line << '.'
          new_line << '.'
        when '@'
          new_line << '@'
          new_line << '.'
        else
          binding.pry
        end
      end

      new_map << new_line
    end

    new_map
  end
end

# part1 = Part1.new(map, movements)
# puts part1.solve

part2 = Part2.new(map, movements)
puts part2.solve
