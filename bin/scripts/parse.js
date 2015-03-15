#!/usr/bin/env node

var $ = require('cheerio').load(process.argv[2])
  , result = {
      fragments: {}
    }

$.root().children().each(function () {
  result.fragments[$('.quality', this).text().slice(1, -1)] =
    $('.furl', this).map(function () {
      return $(this).attr('href')
    }).get()
})

console.log(JSON.stringify(result))
