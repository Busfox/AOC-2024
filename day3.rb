require 'pry'

file = File.open('day3input.txt').read

class Part1
  attr_reader :file

  def initialize(file)
    @file = file.scan(/mul\(\d*,\d*\)/).map do |item|
      item
        .delete_prefix('mul(')
        .delete_suffix(')')
        .split(',')
        .map(&:to_i)
    end
  end

  def solve
    multiplied_list = file.map do |line|
      line[0] * line[1]
    end

    multiplied_list.sum
  end
end

class Part2
  attr_reader :file

  def initialize(file)
    @file = file.scan(/(mul\(\d*,\d*\)|do\(\)|don\'t\(\))/).flatten.map do |item|
      item
        .delete_prefix('mul(')
        .delete_suffix(')')
        .split(',')
    end
  end

  def solve
    to_do = 'do('

    multiplied_list = file.map do |line|
      puts "#{line}"
      if line.size == 1
        to_do = line.first
        nil
      elsif to_do == 'do('
        line[0].to_i * line[1].to_i
      end
    end.compact
    multiplied_list.sum
  end
end

part1 = Part1.new(file)
puts part1.solve
part2 = Part2.new(file)
puts part2.solve

binding.pry