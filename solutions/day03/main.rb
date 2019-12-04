W1, W2 = File.read('data.txt')
    .split("\n")
    .map{ |l| l.scan(/[RLUD]\d+/) }

class Map
    
    def initialize
        @m = {}
    end

    def parse_arr arr, name
        pt = [0, 0]
        steps_taken = 0
        arr.each do |i|
            steps = i[1..-1].to_i
            dir = case i[0]
            when 'R'
                [1, 0]
            when 'L'
                [-1, 0]
            when 'U'
                [0, 1]
            when 'D'
                [0, -1]
            end
            steps.times do
                pt = pt.zip(dir).map(&:sum)
                steps_taken += 1
                last = @m.fetch(pt, {})
                last[name] = last.fetch(name, steps_taken)
                @m[pt] = last
            end
        end
    end

    def part1
        sorted = @m.to_a
            .select { |pt, c| c.keys.count > 1 }
            .sort_by { |pt, c| pt.map(&:abs).sum }

        closest = sorted.first.first.map(&:abs).sum
        closest
    end

    def part2
        sorted = @m.to_a
            .select { |pt, c| c.keys.count > 1 }
            .sort_by { |pt, c| c.map(&:last).sum }

        sorted.first.last.map(&:last).sum
    end
end

m = Map.new
m.parse_arr W1, :first
m.parse_arr W2, :second

puts 'Part 1: %s' % m.part1
puts 'Part 2: %s' % m.part2