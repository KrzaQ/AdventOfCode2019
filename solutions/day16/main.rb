require 'json'
require_relative '../common/intcode'

DATA = File.read('data.txt').scan(/\d/).map(&:to_i)
OFFSET = DATA[0...7].join.to_i

def make_pattern n, len
    [0, 1, 0, -1]
        .map{ |v| [v] * n }
        .flatten
        .cycle
        .take(len + 1)
        .drop(1)
end

def phase arr
    arr.size.times.map do |n|
        arr.zip(make_pattern n + 1, arr.size)
            .map{ |a| a.reduce(&:*) }
            .sum
            .to_s[-1]
    end.join.scan(/\d/).map(&:to_i)
end

def do_n_phases arr, n
    n.times{ |n| arr = phase arr }
    arr
end

def partial_phase arr, offset
    raise :nope unless offset > arr.size / 2

    r = []
    sum = 0
    arr[offset..-1].reverse.each do |n|
        sum += n
        sum %= 10
        r.push sum
    end
    Array.new(offset) + r.reverse
end

def do_n_partial_phases arr, offset, n
    n.times do |n|
        arr = partial_phase arr, offset
    end
    arr
end

def part2
    r = do_n_partial_phases DATA*10000, offset, 100
    r[offset...(offset+8)].join
end

PART1 = do_n_phases(DATA, 100)[0...8].join
PART2 = do_n_partial_phases(DATA * 10_000, OFFSET, 100).drop(OFFSET)[0...8].join

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
