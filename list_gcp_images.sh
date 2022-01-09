#!/bin/sh
#https://gist.github.com/elhmn/22fae23672d5e0edf9ff79506f355be2
hosts="eu.gcr.io gcr.io"
list_container_images() {
	p=$@
	for project in $p; do
		echo "$project: "
		list_container_images $(gcloud container images list --repository=$project 2>/dev/null | tail +2)
		gcloud container images list-tags $project 2>/dev/null | tail +2
		echo ""
	done;
}
for host in $hosts; do
	projects=$(gcloud projects list | tail +2 | awk -v host="$host" '{printf ("%s/%s\n", host, $1)}')
	list_container_images $projects
done;
