APP=acceptessa2-mail-sender
REPO=$(aws ecr describe-repositories --repository-names $APP --query "repositories[0].repositoryUri" --output text | perl -pe '$_ = (split "/")[0]')
DATE=$(date '+%Y%m%d_%H%M%S')

docker build . -t $APP
docker tag "$APP:latest" "$REPO/$APP:$DATE"

LOCAL_BUILD=$(docker inspect $APP | jq '.[0].RepoDigests[0] | split("@")[1]' -r)
REMOTE_BUILDS=$(aws ecr list-images --repository-name $APP | jq '.imageIds[].imageDigest' -r)

REMOTE_COUNT=$(echo "$REMOTE_BUILDS" | sort | uniq | wc -l)
ALL_COUNT=$(echo "$LOCAL_BUILD\n$REMOTE_BUILDS" | sort | uniq | wc -l)

if [ $ALL_COUNT = $REMOTE_COUNT ]; then
    echo "build is same. skipping..."
else
    echo "build is different. push to ecr..."
    aws ecr get-login-password | docker login --username AWS --password-stdin $REPO
    docker push "$REPO/$APP:$DATE"
    aws lambda update-function-code --function-name $APP --image-uri "$REPO/$APP:$DATE"
fi
