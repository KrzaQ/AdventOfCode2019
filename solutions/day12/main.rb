MOONS = File.read('data.txt').each_line.map{ |l| l.scan(/-?\d+/).map(&:to_i) }

def sum_arr a, b
    a.zip(b).map{ |s| s.reduce(:+) }
end

class MoonSim
    def initialize moons
        @moons = moons.map do |m|
            {
                position: m,
                velocity: [0, 0, 0],
            }
        end
    end

    def one_step
        apply_gravity
        apply_velocity
    end

    def get_moons
        @moons
    end

    def gravity_single moon
        @moons.map do |m|
            moon[:position].zip(m[:position]).map{ |a, b| b <=> a }
        end.inject do |t, c|
            sum_arr t, c
        end
    end

    def apply_gravity
        @moons = @moons.map do |m|
            v = sum_arr m[:velocity], gravity_single(m)
            m.merge({ velocity: v })
        end
    end

    def apply_velocity
        @moons = @moons.map do |m|
            pos = sum_arr *m.values
            m.merge({ position: pos })
        end
    end

    def potential_energy
        @moons.map do |m|
            m[:position].map{ |x| x.abs }.sum
        end.sum
    end

    def kinetic_energy
        @moons.map do |m|
            m[:velocity].map{ |x| x.abs }.sum
        end.sum
    end

    def total_energy
        @moons.map do |m|
            m[:position].map{ |x| x.abs }.sum *
            m[:velocity].map{ |x| x.abs }.sum
        end.sum
    end
end

def sim_n_steps n
    ms = MoonSim.new MOONS
    n.times do
        ms.one_step
    end
    [ms.potential_energy, ms.kinetic_energy, ms.total_energy]
end

def find_loop_with_getter getter
    cache = {}

    ms = MoonSim.new MOONS

    initial = getter[ms.get_moons]

    step = 0
    loop do
        ms.one_step
        step += 1
        return step if getter[ms.get_moons] == initial
    end
end

def find_loop
    gen_getter = lambda do |n|
        lambda do |moons|
            moons.map{ |m| [m[:position][n], m[:velocity][n]] }.flatten
        end
    end

    3.times.map do |n|
        find_loop_with_getter gen_getter[n]
    end.inject(&:lcm)
end

PART1 = sim_n_steps(1000).last
PART2 = find_loop

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
