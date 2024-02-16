# Cloud.gov metrics dashboard

## `/ci`
Deploy stuff!

## `/scripts`
Generates the data using UAA and CF services. If you want some sample data to play with, follow this structure* and paste into a `src/data.json` file:

```
{
  "allowed_reqs": 999999999,
  "blocked_reqs": 99999,
  "total_sandbox_orgs": 999,
  "total_users": 999,
  "total_apps": 999,
  "total_domain_instances": 999,
  "total_database_instances": 999,
  "total_es_instances": 99,
  "total_redis_instances": 99,
  "total_s3_instances": 9,
  "agencies_with_agreement": 999
}
```
\* subject to change


## `/src`
Where the HTML is generated!

If you want to generate the site, you'll need to:
- install the packages: `nvm use && npm i`
- generate a data.json file or paste some mock data (above)
- generate the HTML: `npm run generate-html`
- copy the USWDS images: `npm run copy-uswds-imgs`

Wanna see it locally? `npm run serve`

There's no SASS pre-processing. Write regular CSS if you must; but default to [USWDS utility classes](https://designsystem.digital.gov/utilities/) as much as possible.

## `/public`
All the assets (CSS, Images, etc) and the html files, ready to be hosted statically. 

Most of the USWDS is [served via CDN](https://cdnjs.com/libraries/uswds) rather than compiled locally. We do copy over the USWDS images for a few special cases.
