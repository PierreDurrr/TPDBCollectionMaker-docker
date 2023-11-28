# TPDBCollectionMaker-docker
# WIP

Docker version of this script https://github.com/CollinHeist/TPDbCollectionMaker

This version include a flask webui and a watchdog service that's looking for any in.html file in the /app/data folder and automatically output the result of the command to a ready to use .yml file.

* **Working but code is probably still crappy**
* **Maybe more to come.**

docker build --no-cache -t tpdbcm . && docker run -p 5432:5432 tpdbcm
