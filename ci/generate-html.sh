#!/bin/bash

npm install

# copy data generated in previous step into place
cp ../data/data.json src

# copy USWDS assets that aren't on cdn (images)
npm run copy-uswds-imgs

# generate HTML
npm run generate-html
