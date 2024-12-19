require 'pry'

class Node
  attr_reader :elevation, :coordinates
  attr_accessor :children, :parent, :trailhead_count

  def initialize(elevation, coordinates, parent = nil)
    @elevation = elevation
    @coordinates = coordinates
    @children = []
    @parent = parent
    @trailhead_count = 0
  end

  def origin?
    @elevation == 0
  end

  def destination?
    @elevation == 9
  end
end

class Part1
  def initialize(input)
    @map = input
    @row_boundary = input.first.size
    @column_boundary = input.size
    @zero_positions = find_zero_positions
    @destinations = []
    @trailheads = []
  end

  def solve
    @zero_positions.each do |zero_position|
      depth_first_search(zero_position)
      trailhead_count = @destinations.uniq { |destination| destination.coordinates }.size
      zero_position.trailhead_count += trailhead_count
      @destinations = []
    end
    @zero_positions.sum(&:trailhead_count)
  end

  def depth_first_search(node, steps = 0, inner = false)
    steps += 1
    node.children = find_children(node)
    if steps == 10 && node.children.empty?
      @destinations << node
      @trailheads << node
    end
    node.children.each do |child|
      depth_first_search(child, steps, true)
    end
  end

  def find_children(node)
    [[0, 1], [0, -1], [1, 0], [-1, 0]].map do |dx, dy|
      new_coords = [node.coordinates.first + dx, node.coordinates.last + dy]
      next if out_of_bounds?(*new_coords)

      new_elevation = @map[new_coords.first][new_coords.last]

      next if !even_gradual_uphill_slope?(node, new_elevation)

      Node.new(new_elevation, new_coords, node)
    end.compact
  end

  def find_zero_positions
    @map.each_with_index.map do |row, row_index|
      row.each_with_index.map do |value, column_index|
        Node.new(value, [row_index, column_index]) if value == 0
      end
    end.flatten.compact
  end

  def out_of_bounds?(x, y)
    x < 0 || y < 0 || x >= @column_boundary || y >= @row_boundary
  end

  def even_gradual_uphill_slope?(node, destination_elevation)
    node.elevation + 1 == destination_elevation
  end
end

class Part2 < Part1
  def solve
    super

    @trailheads.size
  end
end

input = ARGF.read.split("\n").map { |line| line.chars.map(&:to_i) }

part1 = Part1.new(input)
puts part1.solve

part2 = Part2.new(input)
puts part2.solve