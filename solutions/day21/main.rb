require 'io/console'
require_relative '../common/intcode'

INST = File.read('data.txt').split(',').map(&:to_i)

def part1
    script = [
        'OR A T',
        'AND B T',
        'AND C T',
        'NOT T J',
        'AND D J',
        'NOT A T',
        'OR T J',
        'WALK',
    ]
    c = Cpu.new INST
    script.each do |s|
        c.write_string s
        c.write_input 10
    end
    c.run
    c.read_all_out.last
end

def part2
    script = [
        'OR A T',
        'AND B T',
        'AND C T',
        'NOT T J',
        'AND D J',
        'AND I T',
        'AND E T',
        'OR H T',
        'AND T J',
        'NOT A T',
        'OR T J',
        'RUN',
    ]
    c = Cpu.new INST
    script.each do |s|
        c.write_string s
        c.write_input 10
    end
    c.run
    c.read_all_out.last
end

puts 'Part 1: %s' % part1
puts 'Part 2: %s' % part2
