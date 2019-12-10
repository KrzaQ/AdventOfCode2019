DATA = File.read('data.txt').each_line.to_a
ASTEROIDS = DATA.each_with_index.map do |line, y|
    line.each_char
        .each_with_index
        .select{ |c, _| c == '#' }
        .map{ |_, x| [x, y] }
end.flatten(1)

def colinear? a, b, c
    val = (a.first - b.first) * (b.last - c.last) -
          (a.last - b.last) * (b.first - c.first)
    val == 0
end

def colinear_same_side? a, b, point
    return false unless colinear? a, b, point
    [a, b, point].sort[1] != point
end

def count_visible_asteroids point
    visible = []
    ASTEROIDS.reject{ |a| a == point }.each do |a|
        visible.push a if visible.none? { |v| colinear_same_side? a, v, point }
    end
    visible.count
end

def angle a, b, c
    Math.atan2(c.last - a.last, c.first - a.first) -
    Math.atan2(b.last - a.last, b.first - a.first)
end

def part1
    ASTEROIDS.map do |xy|
        vis = count_visible_asteroids xy
        [xy, vis]
    end.sort_by{ |xy, vis| vis }.last
end

BEST_POINT, PART1 = part1

def part2 point
    todo = []
    visible = []
    ASTEROIDS.reject{ |a| a == point }.each do |a|
        if visible.none? { |v| colinear_same_side? a, v, point }
            visible.push a
        end
    end

    cust_angle = lambda do |v|
        a = angle(point, [point.first, point.last - 1], v)
        a += Math::PI * 2
        a % (2 * Math::PI)
    end

    sorted = visible
        .map{ |v| [v, cust_angle[v]] }
        .sort_by(&:last)
        .map(&:first)

    sorted[199].first * 100 + sorted[199].last
end

PART2 = part2 BEST_POINT

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
