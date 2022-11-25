const fs = require('fs');
const path = require('path');
const Mustache = require('mustache');

const view = require('./data.json');

const template = fs.readFileSync( __dirname + '/index.html.mustache', 'utf-8');
const output = Mustache.render(template, view);

fs.writeFileSync( __dirname + '/index.html', output);
