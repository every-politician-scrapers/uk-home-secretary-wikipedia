// add_P39.js
module.exports = id => ({
  id,
  claims: {
    P39: {
      value: 'Q2484309', // position held: Home Secretary
      references: {
        P143: 'Q328',    // imported from: English Wikipedia
        P4656: 'https://en.wikipedia.org/wiki/Home_Secretary' // import URL
      },
    }
  }
})
