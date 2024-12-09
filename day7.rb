require 'pry'

class Calibration
  attr_reader :result, :operands
  attr_accessor :solution_found

  def initialize(result, operands)
    @result = result
    @operands = operands
    @solution_found = false
  end

  def solvable?
    @solution_found
  end
end

class Integer
  def concat(other)
    Integer([self, other].join, 10)
  end
end

class Part1
  attr_reader :calibrations
  def initialize(calibrations)
    @calibrations = calibrations
    @operators = [:+, :*]
  end

  def solve
    @calibrations.each do |calibration|
      operator_repeated_permutations = @operators.repeated_permutation(calibration.operands.size - 1)

      operator_repeated_permutations.each do |operators|
        equation = [calibration.operands.first]
        operators.each_with_index do |operator, index|
          equation << operator << calibration.operands[index + 1]
        end

        if evaluate_left_to_right(equation) == calibration.result
          calibration.solution_found = true
          break
        end
      end
    end

    @calibrations.select(&:solvable?).map(&:result).sum
  end

  def evaluate_left_to_right(equation_array)
    result = equation_array[0]
    equation_array.each_with_index do |element, index|
      next if element.is_a?(Integer)

      operator = element
      result = result.send(operator, equation_array[index + 1])
    end

    result
  end
end

class Part2 < Part1
  def initialize(calibrations)
    super
    @operators = [:+, :*, :concat]
  end
end

calibrations = []

ARGF.read.split("\n").each do |line|
  result = line.split(': ')
  operands = result.last.split.map(&:to_i)
  calibrations << Calibration.new(result.first.to_i, operands)
end

part1 = Part1.new(calibrations)
puts part1.solve

part2 = Part2.new(calibrations)
puts part2.solve
