def make_array_with_random_numbers size
  ar = []
  size.times { ar << rand(size) }
  ar
end

def say msg, sec
  printf "%-24s %f\n", msg, sec
end
