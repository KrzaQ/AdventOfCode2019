require_relative '../common/intcode'

INST = File.read('data.txt').split(',').map(&:to_i)

def solve_for n
    c = Cpu.new INST

    c.write_input n

    while not c.finished
        c.execute_one
    end

    ret = nil
    loop do
        tmp = c.read_output
        break unless tmp
        ret = tmp
    end
    ret
end

PART1 = solve_for 1
PART2 = solve_for 5

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
