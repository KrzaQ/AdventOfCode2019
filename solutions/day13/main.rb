require 'io/console'
require_relative '../common/intcode'

INST = File.read('data.txt').split(',').map(&:to_i)

def read_out cpu
    out = []
    while cpu.has_output
        out.push cpu.read_output
    end
    out
end

def part1
    c = Cpu.new INST
    while not c.finished
        c.execute_one
    end
    out = read_out c
    out.each_slice(3).to_a.map(&:last).count 2
end

def update_display_data display_data, new_values
    conv = new_values.each_slice(3).map do |a|
        %i(x y v).zip(a).to_h
    end

    conv.each do |el|
        display_data[el[:y]] = {} unless display_data.has_key? el[:y]
        display_data[el[:y]][el[:x]] = el[:v]
    end

    display_data
end

def display data
    max_x, max_y = data.values.map(&:keys).flatten.max, data.keys.max
    score = data[0][-1]

    if score
        puts "Score: #{score}"
    end
    (0..max_y).each do |y|
        line = (0..max_x).map do |x|
            s = ' |#-*'
            s[data[y][x]]
        end.join
        puts line
    end
end

def follow_ball display_data
    arr = display_data.to_a.map do |y, xv|
        xv.to_a.map{ |x, v| [y, x, v] }
    end.flatten(1)
    ball = arr.select{ |a| a.last == 4 }.first
    paddle = arr.select{ |a| a.last == 3 }.first
    ball[1] <=> paddle[1]
end

def part2 input_getter, display = false
    c = Cpu.new([2] + INST[1..-1])
    display_data = {}
    inputs = []
    loop do
        while not c.finished and not c.awaiting_input
            c.execute_one
        end

        out = read_out(c)
        display_data = update_display_data display_data, out
        display display_data if display
        raw_input = input_getter[]
        inputs.push raw_input
        input = case raw_input
        when /j/
            -1
        when /k/
            0
        when /l/
            1
        when /i/
            follow_ball display_data
        when /q/
            p inputs.join if display
            exit
        else
            p inputs.join if display
            break
        end
        c.write_input input
        c.execute_one
        break if c.finished
    end
    display_data[0][-1]
end

stdin_getter = lambda do
    STDIN.getch
end

def file_getter
    data = File.read('inputs.txt').each_char.to_a
    lambda do
        data.shift
    end
end

PART1 = part1
# for manual playing (ijkl)
# PART2 = part2 stdin_getter, true
PART2 = part2 file_getter, false

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
