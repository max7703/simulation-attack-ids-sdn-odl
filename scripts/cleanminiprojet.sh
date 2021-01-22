# suppression de la configuration miniprojet 
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
ovs-vsctl del-br miniprojet

