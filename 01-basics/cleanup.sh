#!/bin/bash

echo "===== Docker Cleanup ====="

stopped_containers=()

while read -r id; do
    [ -z "$id" ] && continue

    stopped_at=$(docker inspect -f '{{.State.FinishedAt}}' "$id")
    stopped_timestamp=$(date -d "$stopped_at" +%s)
    now=$(date +%s)
    age=$((now - stopped_timestamp))

    if [ "$age" -gt 86400 ]; then
        stopped_containers+=("$id")
        docker inspect -f '{{.Name}} - {{.State.FinishedAt}}' "$id"
    fi
done < <(docker ps -aq --filter "status=exited")

echo ""
echo "===== Dangling Images ====="

dangling_images=$(docker images -q -f dangling=true | sort -u)

if [ ${#stopped_containers[@]} -eq 0 ] && [ -z "$dangling_images" ]; then
    echo "Nothing to clean up."
    exit 0
fi

echo ""
read -r -p "Do you want to delete these resources? (y/N): " confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    if [ ${#stopped_containers[@]} -gt 0 ]; then
        docker rm "${stopped_containers[@]}"
    fi

    if [ -n "$dangling_images" ]; then
        docker rmi $dangling_images
    fi

    echo "Cleanup completed."
else
    echo "Cleanup cancelled."
fi
