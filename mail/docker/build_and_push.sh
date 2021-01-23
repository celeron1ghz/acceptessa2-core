APP=acceptessa2-mail-sender
REPO=$(aws ecr describe-repositories --repository-names $APP --query "repositories[0].repositoryUri" --output text | perl -pe '$_ = (split "/")[0]')

docker build . -t $APP
docker tag "$APP:latest" "$REPO/$APP:latest"
aws ecr get-login-password | docker login --username AWS --password-stdin $REPO
docker push "$REPO/$APP:latest"