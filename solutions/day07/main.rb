INST = File.read('data.txt').split(',').map(&:to_i)

class Cpu
    def initialize instructions
        @i = instructions.clone
        @ip = 0
        @out = []
        @in = []
        @awaiting_input = false
        @finished = false
    end

    def write_input val
        @in.push val
    end

    def read_output
        @out.shift
    end

    def peek_last_output
        @out.last
    end

    def awaiting_input
        @awaiting_input
    end

    def has_input
        @in.size > 0
    end

    def has_output
        @out.size > 0
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
            if has_input
                @i[@i[@ip+1]] = @in.shift
                @ip += 2
                @awaiting_input = false
            else
                @awaiting_input = true
            end
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

def one_pass phase, input
    c = Cpu.new INST
    c.write_input phase
    c.write_input input
    while not c.finished
        c.execute_one
    end
    c.peek_last_output
end

def process_for arr
    ret = arr.reduce(0){ |input, phase| one_pass phase, input }
end

def p1
    (0..4).to_a.permutation.map{ |arr| process_for arr }.sort.last
end

def continuous_pass arr
    thrusters = (0..4).map{ Cpu.new INST }

    arr.zip(0..4).each{ |input, idx| thrusters[idx].write_input input }
    thrusters.first.write_input 0

    idx = 0

    last_out = nil

    loop do
        c = thrusters[idx]
        idx += 1
        idx = idx % 5
        n = thrusters[idx]
        while [c.has_output, c.finished, c.awaiting_input].none?
            c.execute_one
        end
        if c.has_output
            tmp = c.read_output
            last_out = tmp if idx == 0
            n.write_input tmp
        end

        break if thrusters.all?{ |t| t.finished }

    end

    last_out
end

def p2
    (5..9).to_a.permutation.map{ |arr| continuous_pass arr }.sort.last
end


puts 'Part 1: %s' % p1
puts 'Part 2: %s' % p2