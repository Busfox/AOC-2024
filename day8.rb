require 'pry'

class Antinode
  attr_reader :position
  def initialize(position, parent_antennas)
    @position = position
    @parent_antennas = parent_antennas
  end
end

class Antenna
  attr_reader :frequency, :position

  def initialize(position, frequency)
    @position = position
    @frequency = frequency
  end
end

class Part1
  def initialize(input)
    @input = input
    @antennas = []
    find_antennas
    @row_boundary = input.first.size
    @column_boundary = input.size
    @distinct_frequencies = @antennas.map(&:frequency).uniq
    solve
  end

  def find_antennas
    @input.each_with_index do |row, row_index|
      row.each_with_index do |value, column_index|
        @antennas << Antenna.new([row_index, column_index], value) unless value == '.'
      end
    end
  end

  def antennas_by_frequency
    @antennas.group_by(&:frequency).values
  end

  def out_of_bounds?(x, y)
    x < 0 || y < 0 || x >= @row_boundary || y >= @column_boundary
  end

  def extend_line(x, y, x_distance_diff, y_distance_diff)
    x += x_distance_diff
    y += y_distance_diff
    return if out_of_bounds?(x, y)

    [x, y]
  end

  def solve
    antinodes = []
    antennas_by_frequency.each do |antenna_group|
      antenna_group.combination(2) do |antenna1, antenna2|
        x_distance_diff = antenna2.position.first - antenna1.position.first
        y_distance_diff = antenna2.position.last - antenna1.position.last
        antinode1_position = extend_line(antenna1.position.first, antenna1.position.last, -x_distance_diff, -y_distance_diff)
        antinode2_position = extend_line(antenna2.position.first, antenna2.position.last, x_distance_diff, y_distance_diff)

        antinodes << Antinode.new(antinode1_position, [antenna1, antenna2]) if antinode1_position
        antinodes << Antinode.new(antinode2_position, [antenna1, antenna2]) if antinode2_position
      end
    end

    antinodes.map(&:position).uniq.count
  end
end

class Part2 < Part1
  def extend_line(x, y, x_distance_diff, y_distance_diff, limit: 1)
    line_points = []
    loop do
      x += x_distance_diff
      y += y_distance_diff
      break if out_of_bounds?(x, y)

      line_points << [x, y]
    end
    line_points
  end

  def solve
    antinodes = []
    antennas_by_frequency.each do |antenna_group|
      antenna_group.combination(2) do |antenna1, antenna2|
        antinodes << Antinode.new(antenna1.position, [antenna1, antenna2])
        antinodes << Antinode.new(antenna2.position, [antenna1, antenna2])

        x_distance_diff = antenna2.position.first - antenna1.position.first
        y_distance_diff = antenna2.position.last - antenna1.position.last
        gcd = x_distance_diff.gcd(y_distance_diff)
        x_distance_diff /= gcd
        y_distance_diff /= gcd

        line_points = extend_line(antenna1.position.first, antenna1.position.last, -x_distance_diff, -y_distance_diff) + extend_line(antenna2.position.first, antenna2.position.last, x_distance_diff, y_distance_diff)

        line_points.each do |position|
          antinodes << Antinode.new(position, [antenna1, antenna2])
        end
      end
    end

    antinodes.map(&:position).uniq.count
  end
end

input = ARGF.read.split("\n").map(&:chars)

part1 = Part1.new(input)
puts part1.solve

part2 = Part2.new(input)
puts part2.solve