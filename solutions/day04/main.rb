MIN, MAX = [265275, 781584]

def verify_p1 n
    s = n.to_s
    rising = s.each_char.each_cons(2).all?{ |a, b| a <= b }
    rising and s =~ /(\d)\1/
end

def verify_p2 n
    s = n.to_s
    rising = s.each_char.each_cons(2).all?{ |a, b| a <= b }
    rising and s.gsub(/(\d)\1\1+/, '') =~ /(\d)\1/
end

PART1 = (MIN..MAX).select do |n|
    verify_p1 n
end.size
PART2 = (MIN..MAX).select do |n|
    verify_p2 n
end.size

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
