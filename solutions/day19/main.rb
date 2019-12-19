require 'io/console'
require_relative '../common/intcode'

INST = File.read('data.txt').split(',').map(&:to_i)

def get_arr_xy arr, x, y
    return nil if x < 0 or y < 0
    arr.fetch(y, [])[x]
end

def sum_arr a, b
    a.zip(b).map{ |s| s.reduce(:+) }
end

def check_xy x, y
    c = Cpu.new INST
    c.write_input x
    c.write_input y
    c.run
    c.read_output
end

def part1
    (0...50).map do |y|
        (0...50).map do |x|
            check_xy x, y
        end.sum
    end.sum
end

def check_if_fits x, y
    right = check_xy(x + 99, y)
    bottom = check_xy(x, y + 99)
    right == 1 and bottom == 1
end

def part2
    x, y = 1, 1
    loop do
        x += 1
        d = (1..10000).bsearch do |d|
            check_xy(x, y+d) == 0
        end
        y += d - 1
        break if check_if_fits(x, y-99)
    end
    "%d%04d" % [x, y-99]
end

puts 'Part 1: %s' % part1
puts 'Part 2: %s' % part2
