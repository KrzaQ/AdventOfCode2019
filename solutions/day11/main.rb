require_relative '../common/intcode'

INST = File.read('data.txt').split(',').map(&:to_i)

def draw_board board
    maxx, maxy = board.keys.map(&:first).max, board.keys.map(&:last).max
    minx, miny = board.keys.map(&:first).min, board.keys.map(&:last).min
    ss = (miny..maxy).map do |y|
        x =(minx..maxx).map do |x|
            case board[[x, y]]
            when :black
                '.'
            when :white
                '#'
            else
                ' '
            end
        end.join
        puts x
    end
end

def sim initial_value
    c = Cpu.new INST

    board = {}
    cur_pos = [0, 0]
    cur_dir = :up

    next_dir = lambda do |d|
        dirs = %i(up right down left)

        new_idx = dirs.index(cur_dir) + (d == 1 ? 1 : -1)
        dirs[new_idx % dirs.size]
    end

    get_value = lambda do
        while not c.has_output and not c.finished
            c.execute_one
        end
        c.read_output
    end

    draw = nil
    update_pos = lambda do |d|
        cur_dir = next_dir[d]
        dirs = {
            up: [0, -1],
            right: [1, 0],
            down: [0, 1],
            left: [-1, 0],
        }
        cur_pos = cur_pos.zip(dirs[cur_dir]).map{ |c| c.reduce(:+) }
    end

    n = 0
    board[[0,0]] = :white
    while not c.finished
        c.write_input board.fetch(cur_pos, :black) == :black ? 0 : 1
        color = get_value[]
        dir = get_value[]
        next unless color and dir
        n += 1
        board[cur_pos] = color == 0 ? :black : :white
        update_pos[dir]
    end
    board
end

puts 'Part 1: %s' % sim(:black).size
puts 'Part 2:'
draw_board sim :white

