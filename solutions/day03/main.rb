# Note: this version provides inaccurate results. For my case, sometimes the 
# second best result was the actual result.

W1, W2 = File.read('data.txt')
    .split("\n")
    .map{ |l| l.scan(/[RLUD]\d+/) }

class Map
    
    def initialize
        @m = {}
    end

    def parse_arr arr
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
            # p [dir, steps]
            steps.times do
                pt = pt.zip(dir).map(&:sum)
                steps_taken += 1
                last = @m.fetch(pt, {times: 0, steps: []})
                last[:steps].push steps_taken
                last[:times] += 1
                @m[pt] = last
            end
        end
    end

    def part1
        sorted = @m.to_a
            .select { |pt, c| c[:times] > 1 }
            .sort_by { |pt, c| pt.map(&:abs).sum }

        sorted.each do |x|
            p x
        end

        closest = sorted.first.first.map(&:abs).sum
        closest
    end

    def part2
        sorted = @m.to_a
            .select { |pt, c| c[:times] > 1 }
            .sort_by { |pt, c| c[:steps].sum }

        sorted.each do |x|
            p x
        end

        sorted.first.last[:steps].sum
    end
end

m = Map.new
m.parse_arr W1
m.parse_arr W2
p m.part1
p m.part2
