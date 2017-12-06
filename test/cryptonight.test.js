const fs = require('fs')
const cryptonight = require("../cryptonight.js")

test("foo", function() {
  fs.readFile("test/vecs/cryptonight.json", (err, data) => {
    const vecs = JSON.parse(data)
    for (i in vecs) {
      const vec = vecs[i]
      console.log(vec)
      cryptonight()
    }
  })
})
