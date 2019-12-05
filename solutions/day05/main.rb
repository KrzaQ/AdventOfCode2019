INST = File.read('data.txt').split(',').map(&:to_i)

class Cpu
    def initialize instructions
        @i = instructions.clone
        @ip = 0
        @out = []
        @in = []
        @finished = false
    end

    def write_input val
        @in.push val
    end

    def read_output
        @out.shift
    end

    def execute_one
        inst = '%05d' % @i[@ip]
        case @i[@ip] % 100
        when 1
            @i[@ip..(@ip+3)]
            @i[@i[@ip+3]] = get_value(@i[@ip+1], inst[-3]) + get_value(@i[@ip+2], inst[-4])
            @ip += 4
        when 2
            @i[@i[@ip+3]] = get_value(@i[@ip+1], inst[-3]) * get_value(@i[@ip+2], inst[-4])
            @ip += 4
        when 3
            @i[@i[@ip+1]] = @in.shift
            @ip += 2
        when 4
            @out.push get_value(@i[@ip+1], inst[-3])
            @ip += 2
        when 5
            if get_value(@i[@ip+1], inst[-3]) != 0
                @ip = get_value(@i[@ip+2], inst[-4])
            else
                @ip += 3
            end
        when 6
            if get_value(@i[@ip+1], inst[-3]) == 0
                @ip = get_value(@i[@ip+2], inst[-4])
            else
                @ip += 3
            end
        when 7
            pred = get_value(@i[@ip+1], inst[-3]) < get_value(@i[@ip+2], inst[-4])
            @i[@i[@ip+3]] = pred ? 1 : 0
            @ip += 4
        when 8
            pred = get_value(@i[@ip+1], inst[-3]) == get_value(@i[@ip+2], inst[-4])
            @i[@i[@ip+3]] = pred ? 1 : 0
            @ip += 4
        when 99
            @finished = true
        else
            raise :unknown
        end
    end

    def get_value val, mode
        case mode
        when '1'
            val
        when '0'
            @i[val]
        end
    end

    def finished
        @finished
    end
end

def solve_for n
    c = Cpu.new INST

    c.write_input n

    while not c.finished
        c.execute_one
    end

    ret = nil
    loop do
        tmp = c.read_output
        break unless tmp
        ret = tmp
    end
    ret
end

PART1 = solve_for 1
PART2 = solve_for 5

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2