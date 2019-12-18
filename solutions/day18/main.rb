require 'set'

DATA = File.read('data.txt').split("\n")

def get_arr_xy arr, x, y
    return nil if x < 0 or y < 0
    arr.fetch(y, [])[x]
end

def sum_arr a, b
    a.zip(b).map{ |s| s.reduce(:+) }
end

INTIAL_POS = DATA.each_with_index.map do |l, y|
    l.each_char.each_with_index.select{ |c, x| c == '@' }.map{ |c, x| [x, y] }
end.flatten

DIRECTIONS = [[-1,0], [0, 1], [1, 0], [0, -1]]

def find_available data, from_pos, has_keys = []
    traversed = { from_pos => 0 }
    keys = {}
    added = [from_pos]
    loop do
        added_this_round = []
        added.each do |a|
            DIRECTIONS.each do |d|
                new_point = sum_arr a, d
                next if traversed.has_key? new_point
                c = get_arr_xy DATA, *new_point
                dist = traversed[a] + 1
                next unless c
                traversed[new_point] = dist
                if c =~ /[a-z]/

                    keys[c] = {
                        pos: new_point,
                        dist: dist,
                    }
                end
                case c
                when /[a-z#]/
                    added_this_round.push new_point if has_keys.include? c
                when /[\.@]/
                    added_this_round.push new_point
                when /[A-Z]/
                    if has_keys.include? c.downcase
                        added_this_round.push new_point
                    end
                else
                    raise :wtf
                end
            end
        end
        added = added_this_round
        break if added.size == 0
    end
    keys
end

def dijkstraish data, from_pos, has_keys = []
    paths = [
        { keys: has_keys, pos: from_pos, dist: 0 }
    ]
    seen = Set.new

    loop do
        paths = paths.sort_by{ |x| x[:dist] }.reject do |path|
            seen.include? [path[:keys].sort.join, path[:pos]]
        end
        this = paths.shift
        seen.add [this[:keys].sort.join, this[:pos]]
        available = this[:pos].map do |pos|
            find_available(data, pos, this[:keys].sort).map do |av|
                [pos, av]
            end
        end.flatten(1)
        to_add = available.reject do |a|
            this[:keys].include? a.last.first
        end.map do |pos, kv|
            k, v = *kv
            np = this[:pos].reject{ |x| x == pos } + [v[:pos]]
            {
                keys: this[:keys] + [k],
                pos: np.sort,
                dist: this[:dist] + v[:dist],
            }
        end
        return this if to_add.size == 0
        paths += to_add
    end
end

def part1
    dijkstraish(DATA, [INTIAL_POS])[:dist]
end

def part2
    d = DATA
    d[INTIAL_POS.last - 1][INTIAL_POS.first - 1] = '@'
    d[INTIAL_POS.last + 1][INTIAL_POS.first - 1] = '@'
    d[INTIAL_POS.last - 1][INTIAL_POS.first + 1] = '@'
    d[INTIAL_POS.last + 1][INTIAL_POS.first + 1] = '@'
    d[INTIAL_POS.last + 1][INTIAL_POS.first + 0] = '#'
    d[INTIAL_POS.last - 1][INTIAL_POS.first + 0] = '#'
    d[INTIAL_POS.last + 0][INTIAL_POS.first + 1] = '#'
    d[INTIAL_POS.last + 0][INTIAL_POS.first - 1] = '#'
    d[INTIAL_POS.last + 0][INTIAL_POS.first + 0] = '#'

    positions = [[-1, -1], [1, -1], [-1, 1], [1, 1]].map do |pos|
        sum_arr INTIAL_POS, pos
    end

    dijkstraish(d, positions)[:dist]
end

PART1 = part1
PART2 = part2
puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
