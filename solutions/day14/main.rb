DATA = File.read('data.txt')
    .each_line
    .select{ |l| l =~ /=>/ }
    .map{ |l| l.scan(/(\d+) (\w+)/) }
    .map{ |arr| arr.map{ |pair| [pair.first.to_i, pair.last ] } }
    .map{ |arr| [ arr.last.last, { input: arr[0...-1], amount: arr.last.first } ] }
    .to_h
    .freeze

def count_refs root
    return {} if root == 'ORE'

    DATA[root][:input].map do |_, mat|
        count_refs(mat).merge({ mat => 1 })
    end.inject({}) do |t, c|
        t.merge(c){ |_, a, b| a + b }
    end
end

def round_up_mod_n val, mod
    (val + mod - 1) / mod * mod
end

def calculate_requirements multiplier = 1
    multiplier = multiplier.floor
    refs = DATA['FUEL'][:input]
        .map{ |_, m| count_refs m }
        .inject({}){ |t, n| t.merge(n){ |_, a, b| a + b } }
    refs.delete 'ORE'

    current_set = DATA['FUEL'][:input]
        .select{ |_, m| refs.fetch(m, 0) == 0 }
        .map{ |a, b| [[a * multiplier, 1], b] }
    current_reqs = DATA['FUEL'][:input]
        .select{ |_, m| refs.fetch(m, 0) != 0 }
        .map(&:reverse)
        .map{ |k, v| [k, [v * multiplier, 1]] }
        .to_h

    loop do
        current_set.map{ |a, b| [b, a.first] }.to_h.each do |m, a|
            reqd_amount = round_up_mod_n a, DATA[m][:amount]
            ref_strength = current_reqs.fetch(m, [0, 1]).last
            DATA[m][:input].each do |c, i|
                num = c * reqd_amount / DATA[m][:amount]
                current_reqs[i] = current_reqs.fetch(i, [0, 0])
                    .zip([num, ref_strength])
                    .map(&:sum)
                refs[i] -= ref_strength unless i == 'ORE'
            end
            current_reqs.delete m
        end

        current_set = current_reqs
            .reject{ |k, v| k == 'ORE' }
            .select{ |k, v| refs[k] == 0 }
            .map{ |k, v| [v, k] }

        break if current_reqs.keys == ['ORE']
    end
    current_reqs['ORE'].first
end

def part2
    (1..Float::INFINITY).bsearch do |n|
        req = calculate_requirements n
        req > 1000000000000
    end.to_i - 1
end

PART1 = calculate_requirements
PART2 = part2

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
