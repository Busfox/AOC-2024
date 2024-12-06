require 'pry'

rules, updates = ARGF.read.split("\n\n").map { |i| i.split("\n") }
rules = rules.map { |rule| rule.split('|').map(&:to_i)}
updates = updates.map(&:split).map { |update| update.first.split(',').map(&:to_i) }

class Part1
  attr_reader :rules, :updates, :un_ordered

  def initialize(rules, updates)
    @rules = {}
    build_rules_hash(rules)
    @updates = updates
    @un_ordered = []
    @middle_numbers = []
  end

  def solve(list = @updates)
    list.each do |update|
      result = solve_update(update)
      find_middle_number(update, result)
    end
    puts "#{self.class.name}: #{@middle_numbers.sum}"
  end

  def solve_update(update)
    hit = []
    ordered = nil
    update.each do |number|
      ordered = in_correct_order?(hit, number)
      break unless ordered

      hit << number
    end

    ordered
  end

  def find_middle_number(update, result)
    ordered = result
    if ordered
      @middle_numbers << update[(update.size/2).floor]
    else
      @un_ordered << update
    end
  end

  def in_correct_order?(hit, number)
    (hit & @rules[number].to_a).empty? ? true : false
  end

  def build_rules_hash(rules)
    rules.each do |first, second|
      @rules[first] << second if @rules[first]
      @rules[first] = [second] if !@rules[first]
    end
  end
end

class Part2 < Part1
  def initialize(rules, updates)
    super
  end

  def solve_update(update)
    hit = []
    re_process = false
    update.each_with_index do |number, index|
      unless (hit & @rules[number].to_a).empty?
        update[index] = update[index - 1]
        update[index - 1] = number
        re_process = true
      end
      hit << number
    end

    solve_update(update) if re_process
    true
  end
end

part1 = Part1.new(rules, updates)
part1.solve
part2 = Part2.new(rules, part1.un_ordered)
part2.solve(part1.un_ordered)