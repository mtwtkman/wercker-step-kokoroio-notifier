if [ ! -n "$WERCKER_KOKOROIO_NOTIFIER_ACCESS_TOKEN" ]; then
  error 'Please set the access token.'
  exit 1
fi

if [ ! -n "$WERCKER_KOKOROIO_NOTIFIER_CALLBACK_URL" ]; then
  error 'Please set a callback url.'
  exit 1
fi

if [ "$WERCKER_RESULT" = "passed" ]; then
  message=`echo -e "$WERCKER_KOKOROIO_NOTIFIER_PASSED_MESSAGE"`
else
  message=`echo -e "$WERCKER_KOKOROIO_NOTIFIER_FAILED_MESSAGE"`
fi

api_version=v1
result=`curl -s -X POST\
  -H "X-ACCESS-TOKEN:$WERCKER_KOKOROIO_NOTIFIER_ACCESS_TOKEN" \
  -d "message=$message" \
  "https://kokoro.io/api/$api_version/bot/channels/$WERCKER_KOKOROIO_NOTIFIER_CHANNEL_ID/messages" \
  --ouput "$WERCKER_STEP_TEMP/result.txt" \
  --write-out "%{http_code}"`

if [ "$result" = "200" ]; then
  success "OK~~~~~"
else
  echo -e "`cat $WERCKER_STEP_TEMP/result.txt`"
  fail "OH..."
fi
