require 'pry'

class Part1
  def initialize(input)
    @disk_map = input
    @expanded_disk_map = expand_disk_map
  end

  def solve
    filled_disk_map = fill_empty_indices(@expanded_disk_map)
    calulate_checksum(filled_disk_map)
  end

  def calulate_checksum(disk_map)
    disk_map.each_with_index.sum do |slot, index|
      slot == '.' ? 0 : index * slot
    end
  end

  def fill_empty_indices(disk_map)
    while disk_map.include?('.')
      empty_indices = find_empty_indices(disk_map)

      empty_indices.each do |index|
        disk_map.pop while disk_map.last == '.'
        disk_map[index] = disk_map.pop
        disk_map.compact!
      end
    end

    fill_empty_indices(
      disk_map,
      find_empty_indices(disk_map)
    ) if disk_map.include?('.')

    disk_map
  end

  def expand_disk_map
    @disk_map.each_with_index.with_object([]) do |(slot, index), result|
      entries = index.even? ? [index / 2] * slot : ['.'] * slot
      result.concat(entries)
    end
    @disk_map.each_with_index.with_object([]) do |(slot, index), result|
      entries = index.even? ? [index / 2] * slot : ['.'] * slot
      result.concat(entries)
    end
  end

  def find_empty_indices(disk_map)
    disk_map.each_index.select { |i| disk_map[i] == '.' }
  end
end

class Part2 < Part1
  def get_consecutive_count_of_value(map, slot, start_index)
    map[start_index..].take_while { |value| value == slot }.size
  end

  def find_consecutive_empty_slots(map, length)
    return nil if length > map.size || length <= 0

    map.each_cons(length).with_index do |subarray, index|
      return index if subarray.all? { |value| value == '.' }
    end
    nil
  end

  def fill_empty_indices(disk_map)
    reversed_map = disk_map.reverse
    previous_slot = nil

    reversed_map.each_with_index do |slot, reverse_index|
      next if slot == previous_slot # Skip duplicate slots

      previous_slot = slot
      count = get_consecutive_count_of_value(reversed_map, slot, reverse_index)
      empty_start = find_consecutive_empty_slots(disk_map, count)

      next if empty_start.nil? || empty_start > disk_map.size - reverse_index - 1

      fill_slots(disk_map, empty_start, count, slot, reverse_index)

      reversed_map = disk_map.reverse
    end

    disk_map
  end

  def fill_slots(disk_map, start, count, slot, reverse_index)
    # Replace empty slots with the current slot
    count.times do |offset|
      disk_map[start + offset] = slot
      disk_map[disk_map.size - 1 - reverse_index - offset] = '.'
    end
  end
end

input = ARGF.read.split('').map(&:to_i)

part1 = Part1.new(input)
puts part1.solve

part2 = Part2.new(input)
puts part2.solve