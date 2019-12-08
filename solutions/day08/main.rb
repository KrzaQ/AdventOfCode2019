DATA = File.read('data.txt')

LAYERS = DATA.each_char.to_a.each_slice(150).to_a
LEAST_ZEROS = LAYERS.map(&:join).sort_by{ |l| l.gsub(/[^0]/,'').length }.first

PART1 = LEAST_ZEROS.count('1') * LEAST_ZEROS.count('2')

MERGED = LAYERS.first.zip(*LAYERS[1..-1]).map(&:join)

puts 'Part 1: %s' % p1
MERGED.map{ |s| s.gsub('2', '')[0] }.each_slice(25).each do |s|
    puts s.map{ |el| el ? el : ' ' }.join.gsub('0', ' ')
end