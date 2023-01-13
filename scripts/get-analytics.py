#! /usr/bin/env python3

import os
import requests
import re
import boto3
import datetime
import pytz
from cryptography import x509

utc=pytz.UTC
now  = datetime.datetime.now()
now = utc.localize(now)
yesterday = datetime.datetime.now() - datetime.timedelta(days=1)
yesterday = utc.localize(yesterday)
ninety_days_ago = datetime.datetime.now() - datetime.timedelta(days=91)
ninety_days_ago = utc.localize(ninety_days_ago)

api_root="https://api.gsa.gov/analytics/dap/v1.1"

def fail(message):
    print(message)
    exit(1)

def show_cert_cn(cert, upload_cutoff):
    now  = datetime.datetime.now()
    now = utc.localize(now)
    print(".c.", end='', flush=True)
    if cert['UploadDate'] > upload_cutoff:
        full_cert = iam.get_server_certificate(ServerCertificateName=cert['ServerCertificateName'])
        cert_body=full_cert['ServerCertificate']['CertificateBody']
        x509_cert = x509.load_pem_x509_certificate(cert_body.encode('utf-8'))
        if x509_cert.not_valid_after > datetime.datetime.now():
            domain_name = re.match(rf'<Name\(CN=(.*)\)\>', str(x509_cert.subject))
            if domain_name:
                print(".d.", end='', flush=True)
                return domain_name.group(1)

def usa_total():
    yesterday = datetime.date.today() - datetime.timedelta(days=1) 
    route = "reports/second-level-domain/data"
    payload = { 'api_key': api_key, 'after': yesterday, 'before': datetime.date.today() }
    api_url = api_root + "/" + route
    response = requests.get(api_url, params=payload)
    return sum(item['visits'] for item in response.json())

def domains_total(domains):
    yesterday = datetime.date.today() - datetime.timedelta(days=1) 
    N = 0
    for d in domains:
        if not d:
            continue
        else:
            route = f'domain/{d}/reports/domain/data'
            payload = { 'api_key': api_key, 'after': yesterday, 'before': datetime.date.today() }
            api_url = api_root + "/" + route
            response = requests.get(api_url, params=payload)
            for item in response.json():
                #if item['domain']:
                if item['report_agency']:
                    # print(N)
                    N = N + item['visits']
    print("total: ", N)
    return N


# MAIN

api_key = os.environ.get('USA_API_KEY')
if not api_key:
    fail("Need to set env var USA_API_KEY")

# Create IAM client
iam = boto3.client('iam')
paginator = iam.get_paginator('list_server_certificates')
alb_domains=[]
alb_domains = ['modularcontracting.18f.gov', 'staging.feedthefuture.gov',
'shiny.epa.gov', 'tock.18f.gov', 'pages-dev.cloud.gov',
'pages-staging.cloud.gov', 'pages.cloud.gov', '*.app.cloud.gov',
'*.fr.cloud.gov', '*.pages-dev.cloud.gov', '*.pages-staging.cloud.gov',
'*.pages.cloud.gov', '*.sites.pages-dev.cloud.gov',
'*.sites.pages-staging.cloud.gov', '*.sites.pages.cloud.gov',
'wasteplan.epa.gov', 'crapes.fdic.gov', 'tots.epa.gov', 'tdg-d.fdic.gov',
'developer.nps.gov', 'receivership-d.fdic.gov', 'countryx-d.fdic.gov',
'api.fdic.gov', 'sales.fdic.gov', 'countryx.fdic.gov',
'household-survey-d.fdic.gov', 'iwaste.epa.gov', 'banks-d.data.fdic.gov',
'sales-admin.fdic.gov', 'tip-webcon.nsf.gov', 'dsld.od.nih.gov',
'dpsx-q.fdic.gov', 'household-survey.fdic.gov',
'staging.hses.ohs.acf.hhs.gov', 'efx-d.fdic.gov', 'api.fda.gov',
'receivership-s.fdic.gov', 'api.open.fec.gov', 'api.usa.gov',
'mywaterway.epa.gov', 'lookforwatersense.epa.gov', 'ccd-q.fdic.gov',
'edie-d.fdic.gov', 'countryx-s.fdic.gov', 'api.commerce.gov',
'api.epa.gov', 'api.congress.gov', 'roadmap-q.fdic.gov',
'edie-s.fdic.gov', 'closedbanks-s.fdic.gov', 'edie.fdic.gov',
'receivership.fdic.gov', 'uaaext-q.fdic.gov',
'household-survey-q.fdic.gov', 'publicapi.fcc.gov', 'lew.epa.gov',
'crapes-s.fdic.gov', 'sorndashboard.fpc.gov', 'stage.madeinamerica.gov',
'dev.madeinamerica.gov', 'hses.ohs.acf.hhs.gov', 'sales-s.fdic.gov',
'cra.fdic.gov', 'api.livewire.energy.gov', 'api-stage.open.fec.gov',
'roadmap-s.fdic.gov', 'dpsx.fdic.gov', 'sales-admin-s.fdic.gov',
'designsystem-q.fdic.gov', 'state-tables-q.fdic.gov', 'test.hsesinfo.org',
'dsldapi.od.nih.gov', 'api.ers.usda.gov', 'designsystem-d.fdic.gov',
'ttahub.ohs.acf.hhs.gov', 'designsystem.fdic.gov', 'cra-q.fdic.gov',
'ccd-s.fdic.gov', 'uaaext.fdic.gov', 'api.gsa.gov', 'tdg.fdic.gov',
'banks.data.fdic.gov', 'cms-dev.usa.gov', 'api.waterdata.usgs.gov',
'cra-s.fdic.gov', 'organicapi.ams.usda.gov', 'portal.challenge.gov',
'app.epa.gov', 'dpsx-d.fdic.gov', 'cobra.epa.gov',
'api-tanfdata.acf.hhs.gov', 'api.ftc.gov', 'api.si.edu', 'trm.fdic.gov',
'household-survey-s.fdic.gov', 'roadmap.fdic.gov', 'trm-q.fdic.gov',
'dev-api.foia.gov', 'sales-admin-q.fdic.gov', 'staging.hsesinfo.org',
'radar.epa.gov', 'agriculture.data.gov', 'devstage.nrel.gov',
'owshiny.epa.gov', 'api.nasa.gov', 'state-tables.fdic.gov',
'efx.fdic.gov', 'cms.usa.gov', 'roadmap-d.fdic.gov', 'stage.api.data.gov',
'closedbanks-d.fdic.gov', 'crapes-d.fdic.gov', 'dev-api.openei.org',
'uaa-q.fdic.gov', 'dpsx-s.fdic.gov', 'stg-api.foia.gov',
'sales-q.fdic.gov', 'closedbanks-q.fdic.gov', 'ccd.fdic.gov',
'sales-d.fdic.gov', 'cms-stage.usa.gov', 'api.nal.usda.gov',
'receivership-q.fdic.gov', 'api-staging.regulations.gov',
'designsystem-s.fdic.gov', 'api.openei.org', 'api.govinfo.gov',
'banks-q.data.fdic.gov', 'api.ods.od.nih.gov', 'crapes-q.fdic.gov',
'ccd-d.fdic.gov', 'tdg-q.fdic.gov', 'madeinamerica.gov',
'closedbanks.fdic.gov', 'edie-q.fdic.gov', 'trm-s.fdic.gov',
'uat-api.foia.gov', 'api.eia.gov', 'cra-d.fdic.gov', 'efx-s.fdic.gov',
'nsteps.epa.gov', 'uaa.fdic.gov', 'api.foia.gov', 'sales-admin-d.fdic.gov',
'efx-q.fdic.gov', 'api.regulations.gov', 'acpt-tip-webcon.nsf.gov',
'api.data.gov', 'owapps.epa.gov', 'developer.nrel.gov',
'countryx-q.fdic.gov', 'campd.epa.gov', 'state-tables-d.fdic.gov',
'trm-d.fdic.gov']

# Run this against GovCloud
#for path in ['/domains/production', '/lets-encrypt/production', '/alb/external-domains-production']:
#    page_iterator = paginator.paginate( PathPrefix = path )
#    for page in page_iterator:
#        for cert in (page['ServerCertificateMetadataList']):
#            c = show_cert_cn(cert, ninety_days_ago)
#            if c in alb_domains:
#                continue
#            else:
#                alb_domains.append(c)

# Run this again Com E/W
cdn_domains = []
cdn = boto3.client('cloudfront')
cdn_response = cdn.list_distributions()
for i in cdn_response['DistributionList']['Items']:
        aliases = i['Aliases']['Items']
        cdn_domains = cdn_domains + aliases

all_domains = domains + cdn_domains

cloud_gov_visits = domains_total(all_domains)
usa_visits = usa_total()

print(f'Total visits to cloud.gov sites: {cloud_gov_visits} USA visits {usa_visits} and Percentage { cloud_gov_visits / usa_visits}')
