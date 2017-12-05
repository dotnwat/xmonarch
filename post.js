if (typeof module === "object" && module.exports) {
    module.exports = cryptonight;
} else {
    global.Viz = cryptonight;
}
  
})(this);
