// List of P39 data for this position. Fetch with:
//     wd sparql office-holders.sparql Q<office id> | tee wikidata.json

module.exports = office => `
  SELECT ?statement ?item ?itemLabel ?replaces ?replacesLabel ?replacedBy ?replacedByLabel ?start ?end WHERE {
    ?item p:P39 ?statement.
    ?statement ps:P39 wd:${office}.
    OPTIONAL { ?statement pq:P580 ?start }
    OPTIONAL { ?statement pq:P582 ?end }
    OPTIONAL { ?statement pq:P1365 ?replaces }
    OPTIONAL { ?statement pq:P1366 ?replacedBy }
    SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
  }
  ORDER BY ?start
`
