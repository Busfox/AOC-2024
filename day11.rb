require 'pry'

class StoneSorter
  attr_reader :stone_counts

  def initialize(input)
    @stone_counts = Hash.new(0) # Hash to store stone values and their counts
    input.each { |value| @stone_counts[value] += 1 }
    @cache = {}
  end

  def solve(iteration)
    iteration.times do
      next_stone_counts = Hash.new(0)
      @stone_counts.each do |stone_value, count|
        results = solve_for_rule(stone_value)
        results.each { |result| next_stone_counts[result] += count }
      end

      @stone_counts = next_stone_counts
    end
  end

  def solve_for_rule(stone_value)
    return @cache[stone_value] if @cache[stone_value]

    result = if stone_value == 0
      [1]
    elsif value_digits(stone_value).even?
      size = value_digits(stone_value) / 2
      divisor = 10 ** size # 10 to the power of size
      left = stone_value / divisor
      right = stone_value % divisor
      [left, right]
    else
      stone_value * 2024
    end

    @cache[stone_value] = [result].flatten
  end

  def value_digits(value)
    Math.log10(value).to_i + 1
  end
end

input = ARGF.read.split(" ").map(&:to_i)

part1 = StoneSorter.new(input)
part2 = StoneSorter.new(input)
part1.solve(25)
part2.solve(75)
puts part1.stone_counts.values.sum
puts part2.stone_counts.values.sum
