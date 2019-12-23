require_relative '../common/intcode'

INST = File.read('data.txt').split(',').map(&:to_i)

def part1
    computers = 50.times.map do |n|
        c = Cpu.new INST
        c.write_input n
        c
    end

    loop do
        all_idle = 0
        computers.each_with_index.each do |c, idx|
            c.run
            if c.awaiting_input
                all_idle += 1
                c.write_input -1
            end
            if c.has_output
                c.read_all_out.each_slice(3).each do |slice|
                    id = slice[0]
                    if id == 255
                        return slice.last
                    end
                    if id < computers.size
                        computers[id].write_input_array slice[1..2]
                    else
                        raise id
                    end
                end
            end
        end
    end
end

def part2
    computers = 50.times.map do |n|
        c = Cpu.new INST
        c.write_input n
        c
    end

    nat_y_packets = [nil, nil]
    nat = nil

    loop do
        all_idle = 0
        computers.each_with_index.each do |c, idx|
            c.run
            if c.awaiting_input
                all_idle += 1
                c.write_input -1
            end
            if c.has_output
                c.read_all_out.each_slice(3).each do |slice|
                    id = slice[0]
                    if id == 255
                        nat = slice[1..2]
                    end
                    if id < computers.size
                        computers[id].write_input_array slice[1..2]
                        all_idle -= 1
                    elsif id != 255
                        raise id
                    end
                end
            end
        end
        if all_idle == computers.size and nat
            computers[0].write_input_array nat
            computers[0].run
            nat_y_packets.shift
            nat_y_packets.push nat[1]
            nat = nil
            if nat_y_packets.first == nat_y_packets.last and nat_y_packets.first
                return nat_y_packets.first
            end
        end
    end
end

puts 'Part 1: %s' % part1
puts 'Part 2: %s' % part2
