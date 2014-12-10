MersenneTwister = require "mersennetwister"
rng = new MersenneTwister()

module.exports =
  nextIdx: (arr) -> rng.int() % arr.length
  nextChoice: (arr) -> arr[@nextIdx(arr)]
