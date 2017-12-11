function cryptonight() {
  var x = new Module()
  console.log(x)
  var inbuf = x._malloc(10);
  console.log(inbuf)
  console.log("asdfasdf1")
  var cr = Module.cwrap('cryptonight', null, ["string", "string", "number"])
  console.log(cr);
  console.log(cr("asdf", "asdf", 1))
}
