# Check if n is prime
self.task = (args) ->
  n = args.n
  return prime: false if n is 1
  return prime: true if n is 2
  # Check even first...
  return prime: false if n % 2 is 0
  # Then check up to sqrt(n)
  for i in [3..Math.sqrt(n)] by 2
    if n % i is 0
      return prime: false
  prime: true

