DATA = File.read('data.txt').split.map(&:to_i)

def fuel_req m
        m / 3 - 2
end

def fuel_req_ex m
        sum = fuel_req m
        add = sum
        while add > 0
                add = [fuel_req(add), 0].max
                sum += add
        end
        sum
end

PART1 = DATA.map{ |n| fuel_req n }.sum
PART2 = DATA.map{ |n| fuel_req_ex n }.sum

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
