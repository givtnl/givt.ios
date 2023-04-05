#!/usr/bin/env bash

echo "Executing prebuild script."
if [ "$APPCENTER_BRANCH" == "main" ];
    then
    	echo "Getting collectgroups for prod."
        curl -H "Accept: application/json" https://api.givtapp.net/api/v2/collectgroups/applist > ios/collectGroupsList.json
    else
    	echo "Getting collectgroups for dev or pre."	
        curl -H "Accept: application/json" https://givt-debug-api.azurewebsites.net/api/v2/collectgroups/applist > ios/collectGroupsListDebug.json
fi
