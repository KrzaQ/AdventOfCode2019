DATA = File.read('data.txt').each_line.map{ |l| l.strip.split(')').reverse }.to_h

def orbits_of o
    ret = []
    loop do
        o = DATA[o]
        break unless o
        ret.push o
    end
    ret.reverse
end

def p2
    y = orbits_of 'YOU'
    s = orbits_of 'SAN'
    while y.first == s.first
        y.shift
        s.shift
    end
    y.size + s.size
end

PART1 = DATA.to_a.map(&:first).map{ |o| orbits_of(o).size }.sum
PART2 = p2
puts PART1
puts PART2
