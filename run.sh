if [ ! -n "$WERCKER_KOKOROIO_NOTIFIER_ACCESS_TOKEN" ]; then
  error 'Please set the access token.'
  exit 1
fi

if [ ! -n "$WERCKER_KOKOROIO_NOTIFIER_CHANNEL_ID" ]; then
  error 'Please set a channel_id to notify'
  exit 1
fi

if [ ! -n "$WERCKER_KOKOROIO_NOTIFIER_API_VERSION" ]; then
  WERCKER_KOKOROIO_NOTIFIER_API_VERSION=v1
fi

if [ "$WERCKER_RESULT" = "passed" ]; then
  build_result_emoji=✅
else
  build_result_emoji=❌
fi

git_url="https://$WERCKER_GIT_DOMAIN/$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY"
m1="$build_result_emoji  $WERCKER_RESULT [build]($WERCKER_BUILD_URL)"
m2="for [$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY]($WERCKER_APPLICATION_URL)"
m3="by $WERCKER_STARTED_BY on [$WERCKER_GIT_BRANCH]($git_url/tree/$WERCKER_GIT_BRANCH) ([$WERCKER_GIT_COMMIT]($git_url/commits/$WERCKER_GIT_COMMIT)) "
message="$m1 $m2 $m3"

result=`curl -s -X POST\
  -H "X-ACCESS-TOKEN:$WERCKER_KOKOROIO_NOTIFIER_ACCESS_TOKEN" \
  -d "expand_embed_contents=false&message=$message" \
  "https://kokoro.io/api/$WERCKER_KOKOROIO_NOTIFIER_API_VERSION/bot/channels/$WERCKER_KOKOROIO_NOTIFIER_CHANNEL_ID/messages" \
  --output "$WERCKER_STEP_TEMP/result.txt" \
  --write-out "%{http_code}"`

if [ "$result" = "200" ]; then
  success "OK~~~~~"
else
  echo -e "`cat $WERCKER_STEP_TEMP/result.txt`"
  fail "OH..."
fi
