require 'pry'

file = File.open('day1input.txt').read.split("\n")

left_list = []
right_list = []

file.map do |line|
  split_line = line.split
  left_list << split_line.first.to_i
  right_list << split_line.last.to_i
end

class Part1
  def self.sum_of_sorted_list_differences(list1, list2)
    list1 = list1.sort
    list2 = list2.sort

    differences = list1.map.each_with_index do |line, index|
      (line - list2[index]).abs
    end

    differences.sum
  end
end

class Part2
  attr_reader :left_list, :right_list

  def initialize(left_list, right_list)
    @left_list = left_list
    @right_list = number_of_occurrences_hash(right_list)
  end

  # { 1 => 4, 2 => 0,  }

  def calculate_similarity_score
    left_list.map do |line|
      line * (right_list[line] || 0)
    end.sum
  end

  def number_of_occurrences_hash(list)
    hash = {}
    list.each do |line|
      if hash[line].nil?
        hash[line] = 1
      else
        hash[line] += 1
      end
    end

    hash
  end
end

puts Part1.sum_of_sorted_list_differences(right_list, left_list)
part2 = Part2.new(right_list, left_list)
puts part2.calculate_similarity_score