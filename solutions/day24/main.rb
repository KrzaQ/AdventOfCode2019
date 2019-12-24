require 'set'
DATA = File.read('data.txt').strip.each_line.map(&:strip)

def get_arr_xy arr, x, y
    return nil if x < 0 or y < 0
    arr.fetch(y, [])[x]
end

def sum_arr a, b
    a.zip(b).map{ |s| s.reduce(:+) }
end

ADJACENT = [[0,1], [1, 0], [0, -1], [-1, 0]]

def next_state arr
    5.times.map do |y|
        5.times.map do |x|
            bugs = ADJACENT.count do |dxy|
                '#' == get_arr_xy(arr, *(sum_arr dxy, [x, y]))
            end
            case get_arr_xy(arr, x, y)
            when '#'
                bugs == 1 ? '#' : '.'
            when '.'
                ([1,2].include? bugs) ? '#' : '.'
            else
                raise :wtf
            end
        end.join
    end
end

def bd_rating arr
    5.times.map do |y|
        5.times.map do |x|
            get_arr_xy(arr, x, y) == '#' ? 2**(y*5 + x) : 0
        end.sum
    end.sum
end

def part1
    cache = Set.new
    cur = DATA
    n = 0
    loop do
        if cache.include? cur
            return bd_rating cur
        end
        cache.add cur
        cur = next_state cur
        n += 1
    end
end

def get_arr_xyz arr, x, y, z
    return nil if x < 0 or y < 0 or z < 0
    arr.fetch(z, []).fetch(y, [])[x]
end

def xyz_adjacent x, y
    ret = []
    if x == 0
        ret += [[1, 2, -1], [1, y, 0]]
    end
    if y == 0
        ret += [[2, 1, -1], [x, 1, 0]]
    end
    if x == 4
        ret += [[3, 2, -1], [3, y, 0]]
    end
    if y == 4
        ret += [[2, 3, -1], [x, 3, 0]]
    end
    if x == 1 and y == 2
        ret += [
            [0, 0, 1],
            [0, 1, 1],
            [0, 2, 1],
            [0, 3, 1],
            [0, 4, 1],
            [0, 2, 0],
            [1, 1, 0],
            [1, 3, 0],
        ]
    elsif x == 2 and y == 3
        ret += [
            [0, 4, 1],
            [1, 4, 1],
            [2, 4, 1],
            [3, 4, 1],
            [4, 4, 1],
            [1, 3, 0],
            [2, 4, 0],
            [3, 3, 0],
        ]
    elsif x == 2 and y == 1
        ret += [
            [0, 0, 1],
            [1, 0, 1],
            [2, 0, 1],
            [3, 0, 1],
            [4, 0, 1],
            [1, 1, 0],
            [2, 0, 0],
            [3, 1, 0],
        ]
    elsif x == 3 and y == 2
        ret += [
            [4, 0, 1],
            [4, 1, 1],
            [4, 2, 1],
            [4, 3, 1],
            [4, 4, 1],
            [3, 1, 0],
            [4, 2, 0],
            [3, 3, 0],
        ]
    else
        if x > 0 and x < 4
            ret += [[x-1, y, 0], [x+1, y, 0]]
        end
        if y > 0 and y < 4
            ret += [[x, y-1, 0], [x, y+1, 0]]
        end
    end
    ret
end

def next_state_recursive arr
    z_count = arr.size + 2
    ret = z_count.times.map do |z|
        5.times.map do |y|
            5.times.map do |x|
                bugs = xyz_adjacent(x, y).count do |dxyz|
                    dxyz[-1] += z - 1
                    '#' == get_arr_xyz(arr, *dxyz)
                end
                r = get_arr_xyz(arr, x, y, z - 1)
                r = '.' unless r
                val = case r
                when '#'
                    bugs == 1 ? '#' : '.'
                when '.'
                    ([1,2].include? bugs) ? '#' : '.'
                when '?'
                    raise :wtf unless [2, 2] == [x, y]
                else
                    raise :wtf
                end
                val = '?' if [2, 2] == [x, y]
                val
            end.join
        end
    end

    while ret.first.join == ('.' * 12 + '?' + '.' * 12) do
        ret.shift
    end
    while ret.last.join == ('.' * 12 + '?' + '.' * 12) do
        ret.pop
    end
    ret
end

def part2
    arr = [DATA]
    200.times do
        arr = next_state_recursive arr
    end
    arr.flatten.join.chars.count{ |c| c == '#' }
end

puts 'Part 1: %s' % part1
puts 'Part 2: %s' % part2
