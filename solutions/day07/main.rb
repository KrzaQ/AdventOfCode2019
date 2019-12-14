require_relative '../common/intcode'

INST = File.read('data.txt').split(',').map(&:to_i)

def one_pass phase, input
    c = Cpu.new INST
    c.write_input phase
    c.write_input input
    while not c.finished
        c.execute_one
    end
    c.peek_last_output
end

def process_for arr
    ret = arr.reduce(0){ |input, phase| one_pass phase, input }
end

def p1
    (0..4).to_a.permutation.map{ |arr| process_for arr }.sort.last
end

def continuous_pass arr
    thrusters = (0..4).map{ Cpu.new INST }

    arr.zip(0..4).each{ |input, idx| thrusters[idx].write_input input }
    thrusters.first.write_input 0

    idx = 0

    last_out = nil

    loop do
        c = thrusters[idx]
        idx += 1
        idx = idx % 5
        n = thrusters[idx]
        while [c.has_output, c.finished, c.awaiting_input].none?
            c.execute_one
        end
        if c.has_output
            tmp = c.read_output
            last_out = tmp if idx == 0
            n.write_input tmp
        end

        break if thrusters.all?{ |t| t.finished }

    end

    last_out
end

def p2
    (5..9).to_a.permutation.map{ |arr| continuous_pass arr }.sort.last
end


puts 'Part 1: %s' % p1
puts 'Part 2: %s' % p2
