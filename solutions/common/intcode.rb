class Cpu
    def initialize instructions
        @i = instructions.clone
        @ip = 0
        @out = []
        @in = []
        @awaiting_input = false
        @finished = false
        @rel_base = 0
    end

    def state
        self.instance_variables.map do |iv|
            [iv, self.instance_variable_get(iv).clone]
        end.to_h
    end

    def self.from_state s
        c = Cpu.new []
        s.each do |k, v|
            c.instance_variable_set k, v.clone
        end
        c
    end

    def copy_self
        Cpu.from_state state
    end

    def write_input val
        @in.push val
    end

    def write_input_array arr
        @in += arr
    end

    def read_output
        @out.shift
    end

    def peek_last_output
        @out.last
    end

    def read_all_out
        o = @out
        @out = []
        o
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
            v = get_value(@i[@ip+1], inst[-3]) + get_value(@i[@ip+2], inst[-4])
            set_value(3, inst[-5], v)
            @ip += 4
        when 2
            v = get_value(@i[@ip+1], inst[-3]) * get_value(@i[@ip+2], inst[-4])
            set_value(3, inst[-5], v)
            @ip += 4
        when 3
            if has_input
                set_value(1, inst[-3], @in.shift)
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
            set_value(3, inst[-5], pred ? 1 : 0)
            @ip += 4
        when 8
            pred = get_value(@i[@ip+1], inst[-3]) == get_value(@i[@ip+2], inst[-4])
            set_value(3, inst[-5], pred ? 1 : 0)
            @ip += 4
        when 9
            @rel_base += get_value(@i[@ip+1], inst[-3])
            @ip += 2
        when 99
            @finished = true
        else
            raise :unknown
        end
    end

    def run
        execute_one unless finished
        while not awaiting_input and not finished
            execute_one
        end
    end

    def get_value val, mode
        case mode
        when '2'
            if @rel_base + val > @i.size
                @i += [0] * (@rel_base + val - @i.size + 1)
            end
            @i[@rel_base + val]
        when '1'
            val
        when '0'
            if val > @i.size
                @i += [0] * (val - @i.size + 1)
            end
            @i[val]
        end
    end

    def set_value val_idx, mode, new_val
        val = @i[@ip + val_idx]
        case mode
        when '2'
            @i[@rel_base + val] = new_val
        when '1'
            raise :wtf
        when '0'
            @i[val] = new_val
        end
    end

    def finished
        @finished
    end
end
