require 'pry'

class Region
  attr_accessor :area, :perimeter, :coordinates, :plant, :corners

  def initialize(plant)
    @plant = plant
    @perimeter = 0
    @area = 0
    @coordinates = []
    @corners = 0
  end
end

class Part1
  def initialize(input)
    @garden = input
    @row_boundary = input.first.size
    @column_boundary = input.size
    @plants = {}
    get_coords_by_flower
    @regions = []
  end

  def solve
    @plants.keys.each do |key|
      find_regions(key)
    end

    @regions.sum do |region|
      region.area * region.perimeter
    end
  end

  def find_regions(target)
    plant_positions = @plants[target]
    while !plant_positions.empty? do
      queue = [plant_positions.first]
      seen = []
      region_number = 1
      while !queue.empty? do
        position = queue.first
        region = Region.new(target) if seen.empty?
        region.area += 1
        region.coordinates << position
        seen << position
        neighbours = find_same_neighbours(*position, target)
        region.perimeter += (4 - neighbours.size)

        queue += neighbours.reject { |neighbour| queue.include?(neighbour) || seen.include?(neighbour) }
        queue = queue.drop(1)
      end

      region_number += 1
      @regions << region
      plant_positions = plant_positions - seen
    end
  end

  def get_coords_by_flower
    @garden.each_with_index do |row, row_index|
      row.each_with_index do |plant, column_index|
        @plants[plant] = [] unless @plants[plant]
        @plants[plant] << [row_index, column_index]
      end
    end
  end

  def find_same_neighbours(row_index, column_index, plant)
    [[0, 1], [0, -1], [1, 0], [-1, 0]].map do |x, y|
      new_coords = [row_index + x, column_index + y]

      new_coords if touching_previous_same_plant?(*new_coords, plant)
    end.compact
  end

  def out_of_bounds?(x, y)
    x < 0 || y < 0 || x >= @column_boundary || y >= @row_boundary
  end

  def touching_previous_same_plant?(x, y, plant)
    return false if out_of_bounds?(x, y)

    @garden[x][y] == plant
  end
end

class Part2 < Part1
  def solve
    super

    @regions.each do |region|
      find_corners(region)
    end

    @regions.sum do |region|
      region.area * region.corners
    end
  end

  def get_2d_array_value(row_index, column_index)
    return @garden[row_index]&.[](column_index) unless out_of_bounds?(row_index, column_index)
    nil
  end

  def find_corners(region)
    sorted = region.coordinates.sort
    sorted.each do |coords|
      x, y = coords
      find_outer_corners(x, y, region)
      find_inner_corners(x, y, region)
    end
  end

  def find_inner_corners(x, y, region)
    if ((get_2d_array_value(x + 1, y - 1) == region.plant && region.coordinates.include?([x+1, y-1])) &&
      (get_2d_array_value(x, y - 1) != region.plant ||
      get_2d_array_value(x + 1, y) != region.plant))

      if (get_2d_array_value(x, y - 1) != region.plant &&
        get_2d_array_value(x + 1, y) != region.plant)

        region.corners += 2
      else
        region.corners += 1
      end
    end

    if ((get_2d_array_value(x + 1, y + 1) == region.plant && region.coordinates.include?([x+1, y+1])) &&
      (get_2d_array_value(x, y + 1) != region.plant ||
      get_2d_array_value(x + 1, y) != region.plant))

      if (get_2d_array_value(x, y + 1) != region.plant &&
        get_2d_array_value(x + 1, y) != region.plant)

        region.corners += 2
      else
        region.corners += 1
      end
    end
  end

  def find_outer_corners(x, y, region)
    if (get_2d_array_value(x + 1, y) != region.plant &&
       get_2d_array_value(x, y + 1) != region.plant) &&
       (get_2d_array_value(x + 1, y + 1) != region.plant || !region.coordinates.include?([x+1, y+1]))

      region.corners += 1
    end

    if (get_2d_array_value(x + 1, y) != region.plant &&
       get_2d_array_value(x, y - 1) != region.plant) &&
       (get_2d_array_value(x + 1, y - 1) != region.plant || !region.coordinates.include?([x+1, y-1]))

       region.corners += 1
    end

    if (get_2d_array_value(x - 1, y) != region.plant &&
       get_2d_array_value(x, y - 1) != region.plant) &&
       (get_2d_array_value(x - 1, y - 1) != region.plant || !region.coordinates.include?([x-1, y-1]))

       region.corners += 1
    end


    if (get_2d_array_value(x - 1, y) != region.plant &&
       get_2d_array_value(x, y + 1) != region.plant) &&
       (get_2d_array_value(x - 1, y + 1) != region.plant || !region.coordinates.include?([x-1,y+1]))

       region.corners += 1
    end
  end
end

input = ARGF.read.split("\n").map(&:chars)

part1 = Part1.new(input)
puts part1.solve


part2 = Part2.new(input)
puts part2.solve