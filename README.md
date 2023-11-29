# TPDBCollectionMaker-docker
# WIP

![screenshot](https://github.com/PierreDurrr/TPDBCollectionMaker-docker/blob/webui/screenshot.png)

Docker version of this script https://github.com/CollinHeist/TPDbCollectionMaker

This version include a flask webui and a watchdog service that's looking for any in.html file in the /app/data folder and automatically output the result of the command to a ready to use .yml file.

* **Working but code is probably still crappy**
* **Ability to view/download generated files not working yet**
* **Maybe more to come.**

docker build --no-cache -t tpdbcm . && docker run -p 5432:5432 tpdbcm
