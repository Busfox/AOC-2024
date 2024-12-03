require 'pry'

file = File.open('day2input.txt').read.split("\n").map { |x| x.split.map(&:to_i) }

class Part1
  attr_reader :file, :differences

  def initialize(file)
    @file = file
    @differences = {}
    @confirmed_safe_indexes = []
    parse_reports
  end

  def parse_reports
    file.each_with_index.each do |report, index|
      determine_differences(report, index)
      is_safe = safe?(differences[index])
      @confirmed_safe_indexes << index if is_safe
    end
  end

  def determine_differences(report, index)
    differences[index] = report.each_cons(2).map do |pair|
      pair.first - pair.last
    end
  end

  def safe?(report_differences)
    same_direction?(report_differences) && between_zero_and_four?(report_differences)
  end

  def same_direction?(report)
    report.all?(&:positive?) || report.all?(&:negative?)
  end

  def between_zero_and_four?(report)
    report.all? { |i| i.abs > 0 && i.abs < 4}
  end

  def safe_count
    puts @confirmed_safe_indexes.size
  end
end

class Part2 < Part1
  def initialize(file)
    super
    parse_reports_with_tolerance
  end

  def parse_reports_with_tolerance
    file.each_with_index do |report, file_index|
      next if @confirmed_safe_indexes.include?(file_index)

      result = report.each_with_index.map do |report_value, report_index|
        temp_differences = if report_index == (report.size - 1)
          differences[file_index].reject.with_index { |i, index| index == report_index - 1 }
        elsif report_index.zero?
          differences[file_index].reject.with_index { |i, index| index == report_index }
        else
          reduced_differences = differences[file_index].reject.with_index { |i, index| index == report_index }
          reduced_differences[report_index - 1] += differences[file_index][report_index]
          reduced_differences
        end

        safe?(temp_differences)
      end

      @confirmed_safe_indexes << file_index if result.include?(true)
    end
  end
end

part1 = Part1.new(file)
part1.safe_count

part2 = Part2.new(file)
part2.safe_count
