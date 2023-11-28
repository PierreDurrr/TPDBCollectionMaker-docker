# TPDBCollectionMaker-docker
# WIP

Docker version of this script https://github.com/CollinHeist/TPDbCollectionMaker

This version include a watchdog service that's looking for any in.html file in the /app/data folder and automatically output the result of the command to a ready to use .yml file

* **Output not working yet**

docker build --no-cache -t tppp . && docker run -p 5432:5432 tppp
