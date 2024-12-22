require 'pry'

input = ARGF.read.split.map(&:chars)

class Path
  attr_reader :start_position, :end_position
  attr_accessor :path, :turns, :facing

  def initialize(start_position, end_position, turns = 0, facing = nil)
    @start_position = start_position
    @end_position = end_position
    @path = []
    @turns = turns
    @facing = facing || '>'
  end

  def solved?
    @path.include?(end_position)
  end

  def starts_at_start?
    @path.include?(start_position)
  end

  def calculate_score
    steps = path.size

    score = (turns * 1000) + steps - 1 # We map the start position, so this accounts for it.
    score
  end
end

class Part1
  MOVEMENT_VECTORS = {
    '>' => [0, 1],
    '<' => [0, -1],
    'v' => [1, 0],
    '^' => [-1, 0]
  }.freeze

  attr_reader :score, :start_position, :end_position, :current_position, :paths
  def initialize(input)
    @input = input
    @score = 0
    @start_position = find_coordinates_by_value('S')
    @end_position = find_coordinates_by_value('E')
    @paths = []
    @traversal_queue = []
    @visited_coords = Hash.new(1000000000)
  end

  def solve
    depth_first_search

    while !@traversal_queue.empty? do
      depth_first_search(@traversal_queue.first)
    end

    possible_paths = paths.select(&:solved?)
    possible_paths.map(&:calculate_score).min
  end

  def find_coordinates_by_value(val)
    flattened_index = @input.flatten.index(val)
    number_of_columns = @input.first.size
    flattened_index.divmod(number_of_columns)
  end

  def depth_first_search(current_path = nil)
    if current_path.nil?
      current_path = Path.new(start_position, end_position)
      current_path.path << start_position
      @traversal_queue << current_path
    end

    current_facing = current_path.facing
    current_turns = current_path.turns
    current_path_steps = current_path.path.map(&:dup)
    position = @traversal_queue.first.path.last
    possible_next_steps = find_possible_next_steps(position)
    possible_next_steps.reject! { |coords| current_path.path.include?(coords) }

    if possible_next_steps.empty?
      @paths << @traversal_queue.shift
      return
    end

    possible_next_steps.each_with_index do |coords, index|
      path = if index.zero?
        current_path
      else
        new_path = Path.new(start_position, end_position, current_turns, current_facing)
        new_path.path = current_path_steps.map(&:dup)
        @traversal_queue << new_path
        new_path
      end

      check_for_turn(position, coords, path)

      path.path << coords

      if end?(coords)
        @paths << @traversal_queue.shift if index.zero?
      end
    end

    score = current_path.calculate_score

    if score > @visited_coords[position]
      @traversal_queue.shift
      return
    end

    @visited_coords[position] = score
  end

  def find_possible_next_steps(position)
    MOVEMENT_VECTORS.values.map do |vector|
      new_coords = coord_math(position, vector)
      next if wall?(new_coords)

      new_coords
    end.compact
  end

  def wall?(position)
    value_at(position) == '#'
  end

  def end?(position)
    value_at(position) == 'E'
  end

  def value_at(position)
    row, col = position
    return nil if row < 0 || col < 0 || row >= @input.size || col >= @input[row].size

    @input[row][col]
  end

  def check_for_turn(current_position, new_position, path)
    vector = coord_math(new_position, current_position, :-)
    new_facing = MOVEMENT_VECTORS.key(vector)
    if coord_math(MOVEMENT_VECTORS[path.facing], MOVEMENT_VECTORS[new_facing]) == [0, 0]
      path.turns += 2
    elsif coord_math(MOVEMENT_VECTORS[path.facing], MOVEMENT_VECTORS[new_facing]).map(&:abs) == [1, 1]
      path.turns +=1
    end

    path.facing = new_facing
  end

  def coord_math(first_coord, last_coord, math_symbol = :+)
    [first_coord.first.send(math_symbol, last_coord.first), first_coord.last.send(math_symbol, last_coord.last)]
  end

  # Determines the movement vector based on the movement character.
  def determine_step(movement)
    MOVEMENT_VECTORS[movement]
  end
end

class Part2 < Part1
  def solve
    min_score = super
    shortest_paths = paths.select { |path| path.solved? && path.calculate_score == min_score }
    shortest_path_positions = shortest_paths.map(&:path).flatten(1).uniq

    shortest_path_positions.size
  end
end
part1 = Part1.new(input)
puts part1.solve

part2 = Part2.new(input)
puts part2.solve
