if [ ! -n "$WERCKER_KOKOROIO_NOTIFIER_ACCESS_TOKEN" ]; then
  error 'Please set the access token.'
  exit 1
fi

if [ ! -n "$WERCKER_KOKOROIO_NOTIFIER_CHANNEL_ID" ]; then
  error 'Please set a channel_id to notify'
  exit 1
fi

message=`cat << EOS
### Build $WERCKER_RESULT\n
[build_url]($WERCKER_BUILD_URL)\n
[run_url]($WERCKER_RUN_URL)\n
[commit](https://$WERCKER_GIT_DOMAIN/$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY/commits/$WERCKER_GIT_COMMIT)\n
branch is $WERCKER_GIT_BRANCH
EOS`


api_version=v1
result=`curl -s -X POST\
  -H "X-ACCESS-TOKEN:$WERCKER_KOKOROIO_NOTIFIER_ACCESS_TOKEN" \
  -d "message=$message" \
  "https://kokoro.io/api/$api_version/bot/channels/$WERCKER_KOKOROIO_NOTIFIER_CHANNEL_ID/messages" \
  --output "$WERCKER_STEP_TEMP/result.txt" \
  --write-out "%{http_code}"`

if [ "$result" = "200" ]; then
  success "OK~~~~~"
else
  echo -e "`cat $WERCKER_STEP_TEMP/result.txt`"
  fail "OH..."
fi
