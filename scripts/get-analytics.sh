#!/bin/bash -o pipefail -e
# -u for unbound vars?

fail(){
  echo $@
  exit 1
}

curlit() {
  curl -s $api_root/${1}?api_key=${api_key}\&after=$yesterday\&before=$today\&limit=10000
}

[ -z "$1" ] && fail "Usage $0 domain"
d=$1

[ -z ${USA_API_KEY:=''} ] && fail "Need to set env var USA_API_KEY"
api_key=${USA_API_KEY}

api_root="https://api.gsa.gov/analytics/dap/v1.1"
yesterday=$(gdate --date "yesterday"  +%Y-%m-%d)
today=$(gdate +%Y-%m-%d)

r=domain/$d/reports/domain/data
echo $r
curlit "$r" | jq '.'

exit

def all_visits(){
  r=reports/second-level-domain/data
  curlit "$r" | jq '.'
}

# all_visits
