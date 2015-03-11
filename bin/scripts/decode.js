#!/usr/bin/env node

function atob() {
  return new Buffer(string, 'base64').toString('binary')
}

var uri = process.argv[2]

if (/^[A-Za-z0-9=\+\/]+$/.test(uri)) {
  uri = atob(uri, true)
} else if (/^[A-Za-z0-9=\-_]+$/.test(uri)) {
  uri = atob(uri.replace(/-/g, '+').replace(/_/g,'/'), true)
}

uri = uri.replace(/^(https?:)##/, '$1//')
console.log(uri)
