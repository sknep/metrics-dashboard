#!/bin/bash

REQUEST_PATH="/v3/apps"

ORG_GUIDS_FILTER=""
if [ -n "$1" ]; then
    ORG_GUIDS_FILTER="organization_guids=$1"
    REQUEST_PATH="$REQUEST_PATH?$ORG_GUIDS_FILTER"
fi

TOTAL_PAGES=$(cf curl "$REQUEST_PATH" | jq -r '.pagination.total_pages')

DOCKER_COUNT=0
DOTNET_COUNT=0
APT_COUNT=0
BINARY_COUNT=0
GO_COUNT=0
NGINX_COUNT=0
NODEJS_COUNT=0
JAVA_COUNT=0
PHP_COUNT=0
PYTHON_COUNT=0
R_COUNT=0
RUBY_COUNT=0
STATICFILE_COUNT=0
OTHER_COUNT=0
NO_COUNT=0

for ((i=1;i <=TOTAL_PAGES ;i++)); do
    # echo "page: $i"
    if [[ $ORG_GUIDS_FILTER != "" ]]; then
        REQUEST_PATH="$REQUEST_PATH&page=$i"
    else
        REQUEST_PATH="$REQUEST_PATH?page=$i"
    fi
    while IFS= read -r resource; do
        LIFECYCLE_TYPE=$(echo "$resource" | jq -r '.lifecycle.type')
        if [[ $LIFECYCLE_TYPE == "docker" ]]; then
            DOCKER_COUNT=$(( DOCKER_COUNT + 1 ))
        else
            BUILDPACK_COUNT=$(echo "$resource" | jq -r '.lifecycle.data.buildpacks | length')
            if [ "$BUILDPACK_COUNT" -eq 0 ]; then
                NO_COUNT=$(( NO_COUNT + 1 ))
            else
                while IFS= read -r buildpack; do
                    case $buildpack in
                        "apt_buildpack" | *apt-buildpack*)
                            APT_COUNT=$(( APT_COUNT + 1 ))
                        ;;

                        "binary_buildpack" | *binary-buildpack*)
                            BINARY_COUNT=$(( BINARY_COUNT + 1 ))
                        ;;

                        "dotnet_core_buildpack" | *dotnet-core-buildpack*)
                            DOTNET_COUNT=$(( DOTNET_COUNT + 1 ))
                        ;;

                        "go_buildpack" | *go-buildpack*)
                            GO_COUNT=$(( GO_COUNT + 1 ))
                        ;;

                        "java_buildpack" | *java-buildpack*)
                            JAVA_COUNT=$(( JAVA_COUNT + 1 ))
                        ;;

                        "nginx_buildpack" | *nginx-buildpack*)
                            NGINX_COUNT=$(( NGINX_COUNT + 1 ))
                        ;;

                        "nodejs_buildpack" | *nodejs-buildpack*)
                            NODEJS_COUNT=$(( NODEJS_COUNT + 1 ))
                        ;;

                        "php_buildpack" | *php-buildpack*)
                            PHP_COUNT=$(( PHP_COUNT + 1 ))
                        ;;

                        "python_buildpack" | *python-buildpack*)
                            PYTHON_COUNT=$(( PYTHON_COUNT + 1 ))
                        ;;

                        "r_buildpack" | *r-buildpack*)
                            R_COUNT=$(( R_COUNT + 1 ))
                        ;;

                        "ruby_buildpack" | *ruby-buildpack*)
                            RUBY_COUNT=$(( RUBY_COUNT + 1 ))
                        ;;

                        "staticfile_buildpack" | *staticfile-buildpack*)
                            STATICFILE_COUNT=$(( STATICFILE_COUNT + 1 ))
                        ;;
                            
                        *)
                            echo "other buildpack: $buildpack"
                            OTHER_COUNT=$(( OTHER_COUNT + 1 ))
                        ;;
                    esac
                done < <( echo "$resource" | jq -cr '.lifecycle.data.buildpacks[]')
            fi
        fi
    done < <( cf curl "$REQUEST_PATH" | jq -c '.resources[]')
done;

echo "total docker apps: $DOCKER_COUNT"
echo "total APT apps: $APT_COUNT"
echo "total Binary apps: $BINARY_COUNT"
echo "total .NET apps: $DOTNET_COUNT"
echo "total Go apps: $GO_COUNT"
echo "total Java apps: $JAVA_COUNT"
echo "total nodeJS apps: $NODEJS_COUNT"
echo "total Nginx apps: $NGINX_COUNT"
echo "total PHP apps: $PHP_COUNT"
echo "total R apps: $R_COUNT"
echo "total Ruby apps: $RUBY_COUNT"
echo "total Python apps: $PYTHON_COUNT"
echo "total static apps: $STATICFILE_COUNT"
echo "total apps using other buildpacks: $OTHER_COUNT"
echo "total apps using no buildpacks: $NO_COUNT"
