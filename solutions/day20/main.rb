require 'set'

DATA = File.read('data.txt').split("\n")

def get_arr_xy arr, x, y
    return nil if x < 0 or y < 0
    arr.fetch(y, [])[x]
end

def sum_arr a, b
    a.zip(b).map{ |s| s.reduce(:+) }
end

DIRECTIONS = [[-1,0], [0, 1], [1, 0], [0, -1]]

MAX_Y, MAX_X = DATA.size, DATA.map(&:size).max

def find_portal x, y
    left = get_arr_xy(DATA, x-1, y)
    right = get_arr_xy(DATA, x+1, y)
    top = get_arr_xy(DATA, x, y-1)
    down = get_arr_xy(DATA, x, y+1)
    this = get_arr_xy(DATA, x, y)
    return nil unless this =~ /[A-Z]/
    r = { dir: :h, xy: [x-1, y], name: left+this } if left =~ /\w/
    r = { dir: :h, xy: [x, y], name: this+right } if right =~ /\w/
    r = { dir: :v, xy: [x, y-1], name: top+this } if top =~ /\w/
    r = { dir: :v, xy: [x, y], name: this+down } if down =~ /\w/
    if r[:xy][1] < 2 or r[:xy][1] > MAX_Y - 3 or
        r[:xy][0] < 2 or r[:xy][0] > MAX_X - 3
        r[:type] = :outer
    else
        r[:type] = :inner
    end
    r
end

def find_xy_next_to_portal x, y
    portal = find_portal x, y
    xy = [[-1, 0], [2, 0]].map do |xy|
        portal[:dir] == :h ? xy : xy.reverse
    end.map do |xy|
        sum_arr(portal[:xy], xy)
    end.select do |xy|
        get_arr_xy(DATA, *xy) == '.'
    end.first
    xy
end

PORTALS = DATA.size.times.map do |y|
        DATA.map(&:size).max.times.map do |x|
            find_portal x, y
        end
    end
    .flatten(1)
    .select(&:itself)
    .sort_by{ |ptl| ptl[:xy] }
    .uniq
    .group_by{ |ptl| ptl[:name] }
    .map do |name, arr|
        if arr.size == 2
            arr[0][:next] = arr[1][:xy]
            arr[1][:next] = arr[0][:xy]
        end
        arr.map{ |el| [el[:xy], el] }
    end
    .flatten(1)
    .to_h

def find_neighbours_with_depth x, y, d
    DIRECTIONS.map do |dx, dy|
        nx, ny = sum_arr [x, y], [dx, dy]
        portal = find_portal(nx, ny)
        nd = d
        if portal and PORTALS[portal[:xy]].has_key? :next
            nx, ny = *find_xy_next_to_portal(*PORTALS[portal[:xy]][:next])
            nd += portal[:type] == :outer ? -1 : 1
        end
        [nx, ny, nd]
    end.select do |x, y, d|
        d >= 0 and get_arr_xy(DATA, x, y) == '.'
    end
end

def dijkstra initial, win_condition
    unknown = [ { xy: initial, dist: 0, depth: 0 } ]
    checked = Set.new
    loop do
        unknown = unknown
            .sort_by{ |x| x[:dist] }
            .reject{ |x| checked.include? [x[:xy], x[:depth]] }
        this = unknown.shift
        available = find_neighbours_with_depth *this[:xy], this[:depth]
        available.reject do |x, y, depth|
            checked.include? [[x, y], depth]
        end.each do |x, y, depth|
            item = { xy: [x, y], dist: this[:dist]+1, depth: depth }
            unknown.push item
        end
        checked.add [this[:xy], this[:depth]]
        return this if win_condition[this]
    end
end

AA = lambda do
    portal = PORTALS.select{ |k, v| v[:name] == 'AA' }.map(&:first).first
    find_xy_next_to_portal *portal
end.call

ZZ = lambda do
    portal = PORTALS.select{ |k, v| v[:name] == 'ZZ' }.map(&:first).first
    find_xy_next_to_portal *portal
end.call

def part1
    win = lambda { |node| node[:xy] == ZZ }
    dijkstra(AA, win)[:dist]
end

def part2
    win = lambda { |node| node[:xy] == ZZ and node[:depth] == 0 }
    dijkstra(AA, win)[:dist]
end

PART1 = part1
puts 'Part 1: %s' % PART1
PART2 = part2
puts 'Part 2: %s' % PART2
