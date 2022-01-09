#!/bin/sh

# e.g. CONTAINER_REGISTRY=asia.gcr.io/your-project-name/gcf/asia-northeast1
CONTAINER_REGISTRY='WRITE YOUR REGISTRY NAME'
LIMIT='unlimited' # change to LIMIT=1 if you want to test small
# DRY_RUN=1 # uncomment this to only list, but not delete
IMAGE_LIST=`gcloud container images list --repository=$CONTAINER_REGISTRY --limit=$LIMIT --format="get(name)"`

for image in $IMAGE_LIST; do
  echo "Image 1: $image"
  DIGEST_LIST=`gcloud container images list-tags $image --format="get(digest)"`
  for digest in $DIGEST_LIST; do
    echo "  -> Digest: $digest"
    if [ -z "$DRY_RUN" ]; then
      gcloud container images delete $image@$digest --force-delete-tags --quiet > /dev/null 2>&1
    fi
  done

  SUB_LIST=`gcloud container images list --repository=$image --format="get(name)"`
  for sub in $SUB_LIST; do
    echo "  Image 2: $sub"
    DIGEST_LIST=`gcloud container images list-tags $sub --format="get(digest)"`
    for digest in $DIGEST_LIST; do
      echo "    -> Digest: $digest"
      if [ -z "$DRY_RUN" ]; then
        gcloud container images delete $sub@$digest --force-delete-tags --quiet > /dev/null 2>&1
      fi
    done
  done
done

# https://gist.github.com/kichiemon/4ba5bf921bc9e4d208db8723da69f0ed
