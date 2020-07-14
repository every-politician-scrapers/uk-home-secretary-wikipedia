module.exports = (id, startdate, enddate, replaces, replacedby) => ({
  id,
  claims: {
    P39: {
      value: 'Q2484309', // position held: Home Secretary
      qualifiers: {
        P580: startdate,
        P582: enddate,
        P1365: replaces,
        P1366: replacedby
      },
      references: {
        P143: 'Q328', // enwiki
        P4656: 'https://en.wikipedia.org/wiki/Home_Secretary' // import URL
      },
    }
  }
})
