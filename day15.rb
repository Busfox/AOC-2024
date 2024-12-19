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

class Part2 < Part1
  WALL = '#'
  ROBOT = '@'
  BOX = ['[',']']
  EMPTY = '.'

  def initialize(map, movement)
    super

    @map = stretch_out_map
    @robot_position = find_robot_starting_position
    @mapped_columns = []
    @mapped_coords = []
  end

  def solve
    @movements.each do |movement|
      print_map
      # sleep(0.1)
      step = determine_step(movement)

      can_move = can_move?(@robot_position, step)

      new_positions_and_values = get_new_positions_and_values(@robot_position, step) if can_move

      move(new_positions_and_values) unless new_positions_and_values.nil?
    end

    print_map

    calculate_box_coordinates_sum
  end

  def calculate_box_coordinates_sum
    @map.each_with_index.sum do |row, row_index|
      row.each_with_index.sum do |char, column_index|
        char == '[' ? (row_index * 100 + column_index) : 0
      end
    end
  end

  def print_map
    @map.each do |m|
      puts "#{m.join(' ')}"
    end
    puts "----------------------------------"
  end

  def get_new_positions_and_values(start_position, step, initial: true)
    if initial
      @mapped_columns = []
      @mapped_coords = []
    end
    # Compute the original line

    original_line = new_positions_and_values_in_line(start_position, step)
    @mapped_columns << start_position.last
    @mapped_coords += original_line.keys
    # Base case: Return if the line is horizontal or vertical with 2 or fewer elements
    return original_line if (moving_vertically?(step) && original_line.size <= 2) || !moving_vertically?(step)

    # Find adjacent boxes and group them by column
    adjacent_boxes = original_line.map { |coords, _| check_for_box_connection(coords, step) }.compact

    grouped_by_column = adjacent_boxes.group_by(&:last).transform_values { |v| v.map(&:first) }

    # Return if we are about to recursively process already processed groups. This avoids an infinite loop
    if !initial
      already_mapped_columns = grouped_by_column.keys & @mapped_columns

      already_mapped_columns.each do |column|
        @mapped_coords.each do |coords|
          # binding.pry if @robot_position == [13,40]
          grouped_by_column[column].delete(coords.first) if coords.last == column
        end
        grouped_by_column.delete(column) if grouped_by_column[column].empty?
      end

      return original_line if grouped_by_column.empty?
    end

    # Recursively process each group
    new_lines = grouped_by_column.flat_map do |column, rows|
      row = MOVEMENT_VECTORS['v'] == step ? rows.min : rows.max
      next if column == start_position.last

      # Recursively get new positions and values for this line
      line = get_new_positions_and_values([row, column], step, initial: false)

      line
    end.compact

    # Combine all lines
    merged_lines = new_lines.inject(original_line) { |result, line| result.merge(line) }

    # if initial && !check_if_all_boxes_are_complete2(@mapped_coords, merged_lines)[:false].empty? && completed_boxes[:false].empty?
      completed_boxes = check_if_all_boxes_are_complete(@mapped_coords, merged_lines)
      # binding.pry if @robot_position == [25,29]
    # end

    return merged_lines if completed_boxes[:false].empty?

    # Recursively process incomplete boxes
    while !completed_boxes[:false].empty?
      completed_boxes[:false].each do |box|
        new_start_position = if merged_lines[box] == ']'
          [box.first - step.first, box.last - 1]
        elsif merged_lines[box] == '['
          [box.first - step.first, box.last + 1]
        end

        merged_lines = get_new_positions_and_values(new_start_position, step, initial: false).merge(merged_lines)
      end

      completed_boxes = check_if_all_boxes_are_complete(@mapped_coords, merged_lines)
    end

    merged_lines
  end

  def check_if_all_boxes_are_complete(mapped_coords, coords_to_move)
    results = { true: [], false: [] }

    coords_to_move.each do |coord, value|
      next unless BOX.include?(value)

      if value == ']' && mapped_coords.include?([coord.first, coord.last - 1])
        results[:true] << coord
      elsif value == '[' && mapped_coords.include?([coord.first, coord.last + 1])
        results[:true] << coord
      else
        results[:false] << coord
      end
    end

    results
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

part1 = Part1.new(map, movements)
puts part1.solve

part2 = Part2.new(map, movements)
puts part2.solve
