INST = File.read('data.txt').each_line.map(&:strip).to_a

def deal stack, num
    ret = Array.new stack.size
    stack.size.times do |n|
        ret[(n * num)%ret.size] = stack.shift
    end
    ret
end

def cut stack, num
    stack.rotate num
end

def new_stack stack
    # p ['new_stack']
    stack.reverse
end

def do_line stack, line
    case line
    when /deal with increment (\d+)/
        deal stack, $1.to_i
    when /cut (-?\d+)/
        cut stack, $1.to_i
    when /deal into new stack/
        new_stack stack
    else
        raise line
    end
end

def part1
    arr = (0...10007).to_a
    INST.each do |l|
        arr = do_line arr, l
    end
    arr.each_with_index.select{ |k, i| k == 2019 }[0][1]
end

#https://rosettacode.org/wiki/Modular_inverse#Ruby
#based on pseudo code from http://en.wikipedia.org/wiki/Extended_Euclidean_algorithm#Iterative_method_2 and from translating the python implementation.
def extended_gcd(a, b)
  last_remainder, remainder = a.abs, b.abs
  x, last_x, y, last_y = 0, 1, 1, 0
  while remainder != 0
    last_remainder, (quotient, remainder) = remainder, last_remainder.divmod(remainder)
    x, last_x = last_x - quotient*x, x
    y, last_y = last_y - quotient*y, y
  end

  return last_remainder, last_x * (a < 0 ? -1 : 1)
end

def invmod(e, et)
  g, x = extended_gcd(e, et)
  if g != 1
    raise 'The maths are broken!'
  end
  x % et
end

GIGA_DECK_SIZE = 119315717514047
GIGA_SHUFFLE_COUNT = 101741582076661

def reverse_idx_lookup idx, line
    case line
    when /deal with increment (\d+)/
        # reverse_deal_idx idx, $1.to_i
        invmod($1.to_i, GIGA_DECK_SIZE) * idx % GIGA_DECK_SIZE
    when /cut (-?\d+)/
        (idx + $1.to_i + GIGA_DECK_SIZE) % GIGA_DECK_SIZE
    when /deal into new stack/
        GIGA_DECK_SIZE - 1 - idx
    else
        raise line
    end
end

def full_reverse_lookup idx
    INST.reverse.each_with_index do |inst, iidx|
        idx = reverse_idx_lookup idx, inst
    end
    idx
end

def part2
    # 119315717514047
    # 101741582076661
    idx = 2020
    idx_y = full_reverse_lookup idx
    idx_z = full_reverse_lookup idx_y
    a = (idx_y-idx_z) * invmod(idx-idx_y+GIGA_DECK_SIZE, GIGA_DECK_SIZE) % GIGA_DECK_SIZE
    b = (idx_y-a*idx) % GIGA_DECK_SIZE

    pow = a.pow(GIGA_SHUFFLE_COUNT, GIGA_DECK_SIZE)

    (pow * idx + (pow-1) * invmod(a-1, GIGA_DECK_SIZE) * b) % GIGA_DECK_SIZE
end

puts 'Part 1: %s' % part1
puts 'Part 2: %s' % part2
