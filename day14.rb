require 'pry'

class Robot
  attr_reader :starting_position, :velocity
  attr_accessor :final_destination, :quadrant

  def initialize(starting_position, velocity)
    @starting_position = starting_position
    @velocity = velocity
    @final_destination = nil
    @quadrant = nil
  end
end

input = ARGF.read.split("\n").map do |line|
  robot = line.split(" ").map { |x| x.gsub(/[a-zA-Z]*=/, '') }
  Robot.new(robot.first.split(',').map(&:to_i), robot.last.split(',').map(&:to_i))
end

class Part1
  def initialize(input, height, width)
    @robots = input
    @height = height
    @width = width
    @dead_row = (height / 2).floor
    @dead_column = (width / 2).floor
  end

  def solve(steps)
    @robots.each do |robot|
      determine_final_destination(robot, steps)
      assign_quandrant(robot)
    end

    quadrant_counts = Hash.new(0)
    @robots.each { |robot| quadrant_counts[robot.quadrant] += 1 if robot.quadrant }
    quadrant_counts.values.inject(:*)
  end

  def determine_final_destination(robot, steps)
    result_x = (robot.starting_position.first + steps * robot.velocity.first) % @width
    result_y = (robot.starting_position.last + steps * robot.velocity.last) % @height
    robot.final_destination = [result_x, result_y]
  end

  def assign_quandrant(robot)
    if robot.final_destination.first < @dead_column
      robot.quadrant = 1 if robot.final_destination.last < @dead_row
      robot.quadrant = 3 if robot.final_destination.last > @dead_row
    elsif robot.final_destination.first > @dead_column
      robot.quadrant = 4 if robot.final_destination.last > @dead_row
      robot.quadrant = 2 if robot.final_destination.last < @dead_row
    end
  end
end

class Part2 < Part1
  def solve(steps)
    (1..steps).each do |step|
      super(step)

      draw_possible_tree(step) if robots_in_line?
      @robots.each { |robot| robot.final_destination = nil}
    end
  end

  def draw_possible_tree(step)
    map = []
    @height.times do |h|
      map << @width.times.map { |_| '.' }
    end

    @robots.each_with_index do |robot, index|
      map[robot.final_destination.last][robot.final_destination.first] = '■'
    end

    map.each { |x| puts "#{x.join}" }

    nil
  end

  def robots_in_line?
    hash = Hash.new(0)
    @robots.map(&:final_destination).each do |x, y|
      hash[x] += 1
    end

    hash.values.any? { |v| v >= 25 }
  end
end

{ foo: 'bar' }

hash[:baz]

part1 = Part1.new(input, 103, 101)
puts part1.solve(100)

part2 = Part2.new(input, 103, 101)
puts part2.solve(100000)