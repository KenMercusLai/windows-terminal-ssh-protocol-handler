# Job Runner

## Description
The job runner is a docker image with tasks for different purposes. 

## Requirements

* Docker for running the images 
* Internet access for downloading the image
* Access of Linkding server from where docker image runs
* A token generated on Linkding

## Features:
* Import bookmarks to Linkding
```shell
docker exec -it linkding-jobs import_bookmarks.py
```
* Update bookmark information
```shell
docker exec -it linkding-jobs update_info.py
```
