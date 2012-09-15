# Check if n is prime
task = (args) ->
  n = args.n
  # Check even first...
  return prime: false if n % 2 is 0
  # Then check up to sqrt(n)
  for i in [3..Math.sqrt(n)] by 2
    if n % i is 0
      return prime: false
  prime: true

console.log task(n: 12)
console.log task(n: 13)
