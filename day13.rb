require 'pry'

class Machine
  attr_accessor :button_a, :button_b, :prize, :possible_solutions, :solution
  def initialize(button_a, button_b, prize, prize_addend = 0)
    @button_a = { X: button_a.first, Y: button_a.last }
    @button_b = { X: button_b.first, Y: button_b.last }
    @prize = { X: prize.first + prize_addend, Y: prize.last + prize_addend }
    @possible_solutions = nil
    @solution = nil
  end

  def solvable?
    !@possible_solutions.nil? && !@possible_solutions.empty?
  end

  def lowest_cost_solution
    lowest = nil

    @possible_solutions.each do |solution|
      button_presses = (solution.first * 3) + solution.last
      lowest = button_presses unless lowest&.<(button_presses)
    end

    @solution = lowest
  end
end

class Part1
  def initialize(input)
    @machine_list = []
    initialize_machines(input)
  end

  def solve
    @machine_list.each do |machine|
      find_possible_solutions(machine)
      machine.lowest_cost_solution
    end

    @machine_list.select(&:solvable?).sum(&:solution)
  end

  def initialize_machines(input)
    input.each do |machine|
      button_a = machine.first.scan(/(\d+)/).flatten.map(&:to_i)
      button_b = machine[1].scan(/(\d+)/).flatten.map(&:to_i)
      prize = machine.last.scan(/(\d+)/).flatten.map(&:to_i)
      @machine_list << Machine.new(button_a, button_b, prize)
    end
  end

  def find_possible_solutions(machine)
    possible_x_solutions = []
    possible_y_solutions = []

    (1..200).each do |i|
      x_result = (machine.prize[:X].to_f - (machine.button_a[:X] * i)) / machine.button_b[:X]
      possible_x_solutions << [i, x_result.to_i] if (x_result % 1).zero? && x_result.positive?

      y_result = (machine.prize[:Y].to_f - (machine.button_a[:Y] * i)) / machine.button_b[:Y]
      possible_y_solutions << [i, y_result.to_i] if (y_result % 1).zero? && y_result.positive?
    end

    machine.possible_solutions = possible_x_solutions & possible_y_solutions
  end
end

class Part2 < Part1
  def initialize_machines(input)
    input.each do |machine|
      button_a = machine.first.scan(/(\d+)/).flatten.map(&:to_i)
      button_b = machine[1].scan(/(\d+)/).flatten.map(&:to_i)
      prize = machine.last.scan(/(\d+)/).flatten.map(&:to_i)
      @machine_list << Machine.new(button_a, button_b, prize, 10000000000000)
    end
  end

  def solve
    @machine_list.each do |machine|
      # Implement Cramer's rule
      # Cross multiply each button values and subtract to find original determinent
      determinant = (machine.button_a[:X] * machine.button_b[:Y]) - (machine.button_a[:Y] * machine.button_b[:X])

      # Do the same for each button with the prize, separately.
      # We're replacing each button coordinates with the prize coordinates to get
      # new determinents
      b_determinent = (machine.button_b[:Y] * machine.prize[:X]) - (machine.button_b[:X] * machine.prize[:Y])
      a_determinent = (machine.button_a[:X] * machine.prize[:Y]) - (machine.button_a[:Y] * machine.prize[:X])

      # if
      if (b_determinent % determinant == 0) && (a_determinent % determinant == 0)
        machine.possible_solutions = [[
          b_determinent / determinant,
          a_determinent / determinant
        ]]
      end
    end

    solvable_machines = @machine_list.select(&:solvable?)


    solvable_machines.each do |machine|
      machine.lowest_cost_solution
    end
    solvable_machines.sum(&:solution)
  end
end

input = ARGF.read.split("\n\n").map { |line| line.split("\n") }

part1 = Part1.new(input)
puts part1.solve

part2 = Part2.new(input)
puts part2.solve