require 'io/console'
require_relative '../common/intcode'

INST = File.read('data.txt').split(',').map(&:to_i)

DIRECTIONS = {
    [ 0, -1] => 1,
    [ 0,  1] => 2,
    [-1,  0] => 3,
    [ 1,  0] => 4,
}

def sum_arr a, b
    a.zip(b).map{ |s| s.reduce(:+) }
end

def draw_map known
    min_x, max_x = known.keys.map(&:first).minmax
    min_y, max_y = known.keys.map(&:last).minmax

    (min_y..max_y).each do |y|
        str = (min_x..max_x).map do |x|
            case known.fetch([x, y], {ret: -1})[:ret]
            when 0
                '#'
            when 1
                '.'
            when 2
                '@'
            when -1
                ' '
            else
                raise :wtf
            end
        end.join
        puts str
    end
end

def bfs initial_state, win_condition, debug = false
    known = { initial_state[:point] => initial_state[:point_data] }
    last_added = [initial_state[:point]]

    iterations = 0
    loop do
        added_this_round = []
        last_added.each do |pair|
            DIRECTIONS.each do |dir, dir_value|
                to_check = sum_arr pair, dir
                next if known[to_check]
                c = Cpu.from_state known[pair][:state]
                c.write_input dir_value
                c.run
                out = c.read_output
                known[to_check] = {
                    len: known[pair][:len] + 1,
                    state: c.state,
                    ret: out,
                }
                case out
                when 0
                    # wall
                when 1
                    added_this_round.push to_check
                when 2
                    added_this_round.push to_check
                else
                    raise 'WTF'
                end
            end
        end
        if debug
            puts '=' * 80
            draw_map known
            gets
        end
        ret = win_condition[known, added_this_round, iterations]
        return ret if ret[:won]
        last_added = added_this_round
        iterations += 1
    end
end

def bfs_p1
    initial_state = {
        point: [0, 0],
        point_data: { len: 0, state: Cpu.new(INST).state, ret: 1 }
    }

    win_condition = lambda do |known, added, iter|
        oxygen = added.select{ |a| known[a][:ret] == 2 }.first
        if oxygen
            {
                known: known,
                point: oxygen,
                len: known[oxygen][:len],
                won: true
            }
        else
            {
                won: false
            }
        end
    end

    bfs initial_state, win_condition
end

def bfs_p2 p1_result
    pt = p1_result[:point]
    state = p1_result[:known][pt][:state]
    initial_state = {
        point: pt,
        point_data: { len: 0, state: state, ret: 2 }
    }

    win_condition = lambda do |known, added, iter|
        if added.size == 0
            {
                known: known,
                len: iter,
                won: true
            }
        else
            {
                won: false
            }
        end
    end

    bfs initial_state, win_condition
end

PART1 = bfs_p1
PART2 = bfs_p2 PART1

puts 'Part 1: %s' % PART1[:len]
puts 'Part 2: %s' % PART2[:len]
