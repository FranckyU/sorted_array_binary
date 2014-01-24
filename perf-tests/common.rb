require 'frugal_timeout'

MonotonicTime = FrugalTimeout::MonotonicTime

def say msg, sec
  printf "%-24s %f\n", msg, sec
end

@ar = []
COUNT = 1000
COUNT.times {
  @ar << rand(COUNT)
}
