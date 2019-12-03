DATA = File.read('data.txt').split(',').map(&:to_i)

SOUGHT_VALUE = 19690720

def calculate data, i1, i2
    rip = 0
    data[1] = i1 if i1
    data[2] = i2 if i2

    loop do
        case data[rip]
        when 1
            data[data[rip+3]] = data[data[rip+1]] + data[data[rip+2]]
            rip += 4
        when 2
            data[data[rip+3]] = data[data[rip+1]] * data[data[rip+2]]
            rip += 4
        when 99
            return [ data.first, :ok ]
        else
            return [ data.first, :err ]
        end
    end
end

def find_sought sought
    (0..99).to_a.product((0..99).to_a).lazy
        .select do |i1, i2|
            r = calculate DATA.clone, i1, i2
            r.first == SOUGHT_VALUE
        end.map do |i1, i2|
            i1 * 100 + i2
        end.first
end

PART1 = calculate DATA.clone, 12, 2
PART2 = find_sought SOUGHT_VALUE

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2.inspect
