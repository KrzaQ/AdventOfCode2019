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
# p lines.size
# p lines[0].size

# p p1

def part1
    c = Cpu.new INST
    c.run
    lines = c.read_all_out.map(&:chr).join.split("\n")
    (0...lines[0].size).map do |x|
        (0...lines.size).select do |y|
            [[-1,0], [0, 1], [1, 0], [0, -1], [0, 0]].all? do |a|
                pt = sum_arr [x, y], a
                '#' == get_arr_xy(lines, pt.first, pt.last)
            end
        end.map do |y|
            x * y
        end.sum
    end.sum
end

def part2
    c = Cpu.new [2] + INST[1..-1]
    c.run
    c.write_input_array 'A,B,A,B,C,C,B,C,B,A'.each_char.map(&:ord)
    c.write_input 10
    c.write_input_array 'R,12,L,8,R,12'.each_char.map(&:ord)
    c.write_input 10
    c.write_input_array 'R,8,R,6,R,6,R,8'.each_char.map(&:ord)
    c.write_input 10
    c.write_input_array 'R,8,L,8,R,8,R,4,R,4'.each_char.map(&:ord)
    c.write_input 10
    c.read_all_out
    c.run
    c.write_input 'y'.ord
    c.write_input 10
    while not c.finished
        c.execute_one
        if c.has_output
            r = c.read_output
            return r if r > 255
            # if r == 10
            #     gets
            # else
            #     print r.chr
            # end
        end
    end
end

PART1 = part1
PART2 = part2
puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2

# R,12,L,8,R,12,R,8,R,6,R,6,R,8,R,12,L,8,R,12,R,8,R,6,R,6,R,8,R,8,L,8,R,8,R,4,R,4,R,8,L,8,R,8,R,4,R,4,R,8,R,6,R,6,R,8,R,8,L,8,R,8,R,4,R,4,R,8,R,6,R,6,R,8,R,12,L,8,R,12

# A,B,A,B,C,C,B,C,B,A
# A = R,12,L,8,R,12
# B = R,8,R,6,R,6,R,8
# C = R,8,L,8,R,8,R,4,R,4


