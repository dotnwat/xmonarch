if (typeof module === "object" && module.exports) {
    module.exports = cryptonight;
} else {
    global.cryptonight = cryptonight;
}
  
})(this);
