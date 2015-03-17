#!/usr/bin/env node

var uri = process.argv[2]
uri = uri.replace(/^(http:\/\/[^\/]*(?:youku|tudou|ku6|yinyuetai|letv|sohu|youtube|iqiyi|facebook|vimeo|cutv|cctv|pptv))xia.com\//, '$1.com/')
uri = uri.replace(/^(http:\/\/[^\/]*(?:bilibili|acfun|pps))xia\.tv\//, '$1.tv/')
uri = uri.replace(/^(https?:)\/\//, '$1##')
uri = (new Buffer(uri, 'binary')).toString('base64')
uri = uri.replace(/\+/g, '-').replace(/\//g, '_')
console.log(uri)
