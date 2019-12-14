require_relative '../common/intcode'

INST = File.read('data.txt').split(',').map(&:to_i)

def sim n
    c = Cpu.new INST
    c.write_input n
    while not c.finished
        c.execute_one
    end
    c.read_output
end

puts 'Part 1: %s' % sim(1)
puts 'Part 2: %s' % sim(2)
