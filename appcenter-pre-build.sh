if [ "$APPCENTER_BRANCH" == "master" ];
    then
        curl -H "Accept: application/json" https://api.givtapp.net/api/v2/collectgroups/applist > ios/collectGroupsList.json
    else
        curl -H "Accept: application/json" https://givt-debug-api.azurewebsites.net/api/v2/collectgroups/applist > ios/collectGroupsListDebug.json
fi
