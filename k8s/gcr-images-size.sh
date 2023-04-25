#!/bin/bash

# Set the project ID as a parameter
PROJECT_ID=$1

# Function to calculate the size of an image
function calculate_image_size() {
  local image_name=$1
  local tag=$2
  local layer_sizes=($(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" https://eu.gcr.io/v2/$PROJECT_ID/$image_name/manifests/$tag | jq -r '.layers[].size'))
  local total_size=$(echo "${layer_sizes[@]}" | sed 's/ /+/g' | bc)
  echo "GCR Image Name: $image_name:$tag"
  echo "Total Size: $total_size bytes"
  echo "Layer Sizes:"
  for i in "${!layer_sizes[@]}"; do
    echo "  Layer $i: ${layer_sizes[$i]} bytes"
  done
}

# Get all installed images from gke
kubectl get pods --all-namespaces -o=jsonpath="{range .items[*]}{.metadata.name}{'\t'}{.spec.containers[*].image}{'\n'}{end}" | sort -u | awk '{print$2}' | while read pod_image; do
  echo $pod_image
  image_name_tag=$(echo $pod_image | awk -F"/" '{print$NF}')
  image_name=$(echo $image_name_tag | awk -F":" '{print$1}')
  tag=$(echo $image_name_tag | awk -F":" '{print$2}')
  calculate_image_size $image_name $tag
done

# ./gcr-image-size.sh [PROJECT-ID]
