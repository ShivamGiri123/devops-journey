#!/bin/bash
service=ssh
max_retries=3
count=1

while [ $count -le $max_retries ]
do
 echo "Attempt $count: Checking $service Services..:"
 
  pgrep -x $service > /dev/null
  status=$?

if [ $status -eq 0 ]; then
    echo "$service is running.."
        exit 0
    else 
    echo "$service is not running.."
    echo "retrying in 5 seconds.."
    sleep 5
fi

 count=$((count+1))
done
echo "service did not start after $max_retries tries.. "
exit 1






