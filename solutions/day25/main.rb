require_relative '../common/intcode'

INST = File.read('data.txt').split(',').map(&:to_i)

def part1
    c = Cpu.new INST

    loop do
        c.run
        puts c.read_all_out.map(&:chr).join
        c.write_input_array gets.chars.map(&:ord)
    end
end

part1
