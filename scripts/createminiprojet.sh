
# executer ce shelle en mode sudo 
# installer openvswitch et ovs-docker 
echo -e "\e[7m   nettoyage de  l'environnement docker et OVS \e[0m"
sudo ./cleanminiprojet.sh
sleep 2
echo -e "\e[7m creation du switch ovs miniprojet\e[0m"
sudo ovs-vsctl add-br miniprojet
sleep 3
echo -e "\e[7m creation des 5 containers herbergeant les différents  serveurs en mode detach\e[0m"
docker run -itd --name sdn_ctl  opendaylight/odl bash
docker run -itd --name posteb amouat/network-utils bash
docker run -itd --name postea  amouat/network-utils bash
docker run -itd --name ids linton/docker-snort bash
docker run -itd --name web_server -p 21:21 -e FTP_USER=user -e FTP_PASSWORD=user panubo/vsftpd
docker ps
sleep  5
echo -e "\e[7m Installation de packages \e[0m"
docker exec ids /bin/sh -c "apt update;apt install -y nano ftp python3 python3-pip net-tools;pip3 install requests --upgrade;mkdir /ftpthreat"
docker exec web_server /bin/sh -c "apt update;apt install -y nano ftp net-tools"
docker exec postea /bin/sh -c "apt update;apt install -y nano ftp net-tools"
docker exec posteb /bin/sh -c "apt update;apt install -y nano ftp net-tools"
sleep 5
echo -e "\e[7m Positionnement des fichiers neccessaires et modification des regles \e[0m"
docker cp putflow.py ids:/ftpthreat/putflow.py
docker cp /home/user/Projet/miniprojetfile/flow/fl1402.json ids:/ftpthreat/fl1402.json
docker cp ftpthreat.sh ids:/ftpthreat/ftpthreat.sh
docker cp snortruleftp.txt ids:/ftpthreat/snortruleftp.txt
docker exec ids /bin/sh -c "chmod 777 -R /ftpthreat"
docker exec ids /bin/sh -c "cat /ftpthreat/snortruleftp.txt >> /etc/snort/rules/local.rules"
sleep 5
echo -e "\e[7m création d’un interface eth1 sur les containers  + attachement de l'interface au port du  switch \e[0m"
echo -e " \e[7m  affectation des addresses ip sur le réseau 192.168.16.X/24 et adresses mac\e[0m"
echo -e "\e[7m NB : la configuration réseau du controleur n'est pas modifiée\e[0m"
sleep 5
echo -e "\e[7m le postea sera attaché au port openflow=1 IP 192.168.16.1 ( les numéros sont attribués par ordre de création)\e[0m" 
ovs-docker add-port miniprojet eth1 postea --ipaddress=192.168.16.1/24 --macaddress="10:00:00:00:00:01"
echo -e "\e[7m le posteb sera attaché au port openflow=2 IP 192.168.16.2\e[0m " 
ovs-docker add-port miniprojet eth1 posteb --ipaddress=192.168.16.2/24 --macaddress="10:00:00:00:00:02\e[0m"
echo -e "\e[7m l'ISD  sera attaché au port openflow=3 IP 192.168.16.3\e[0m " 
ovs-docker add-port miniprojet eth1 ids --ipaddress=192.168.16.3/24   --macaddress="10:00:00:00:00:03\e[0m"
echo -e "\e[7m le Web serveur sera attaché au port openflow=4 IP 192.168.16.4 \e[0m"
ovs-docker add-port miniprojet eth1 web_server --ipaddress=192.168.16.4/24 --macaddress="10:00:00:00:00:04"
echo -e "\e[7m le controleur sera attaché au port openflow=5 IP 192.168.16.5 \e[0m"
ovs-docker add-port miniprojet eth1 sdn_ctl --ipaddress=192.168.16.5/24 --macaddress="10:00:00:00:00:05"

sleep 5
echo -e "\e[7m déconnexion de l’interface par defaut eth0 du bridge docker des containers\e[0m" 
echo -e " \e[7m le container sdn_ctl qui instancie le controleur reste sur la meme  stack ip que le switch pour l'Init, il est accessible à l'adresse 172.17.0.2\e[0m,"
echo -e " \e[7m le controleur est accessible à l'adresse 192.168.16.5 depuis L'IDS \e[0m,"


docker network disconnect bridge postea
docker network disconnect bridge posteb
docker network disconnect bridge ids
docker network disconnect bridge web_server
sleep 5
echo -e "\e[7m demarrage du controleur ODL : karaf \e[0m" 
docker  exec sdn_ctl /opt/opendaylight/bin/start clean
echo  -e "\e[7m tempo de 20 secondes\e[0m"
echo  -e "\e[7m demarrage du  plugins openflow du controleur odl-openflowplugin-flow-services-rest\e[0m "
sleep 10
docker  exec sdn_ctl /opt/opendaylight/bin/client  feature:install odl-openflowplugin-flow-services-rest
echo  -e "\e[7m tempo de 20 secondes\e[0m"
echo  -e "\e[7m demarrage du  plugins openflow du controleur odl-restconf\e[0m "
sleep 10
docker  exec sdn_ctl /opt/opendaylight/bin/client feature:install odl-restconf
echo  -e "\e[7m tempo de 30 secondes\e[0m"
echo -e "\e[7m configuration openflow du switch\e[0m"
sleep 15
sudo ovs-vsctl set bridge miniprojet protocols=OpenFlow14,OpenFlow13
sudo ovs-vsctl set-controller miniprojet tcp:172.17.0.2
echo  -e "\e[7m tempo de 10 secondes\e[0m"
echo -e " \e[7m verification du  switch\e[0m"
sleep 5
sudo ovs-vsctl show
echo -e "\e[7mlancement de la  configuration openflow du swich\e[0m"
echo  -e "\e[7mlancement du script python initswich.py dans le repertoire courant\e[0m"
echo -e "\e[7mce script prend en argument les id des fichier flow json situé dans le repertoire\e[0m"
echo -e "\e[7m../flow  ces fichiers sont de la forme fl<id_flow>.json\e[0m"
echo  -e "\e[7m tempo de 10 secondes\e[0m"
sleep 5
sudo python3 ./initswitchb.py  100 200 300 400 500 101 202 303 404 505
echo  -e "\e[7m tempo de 10 secondes\e[0m"
echo -e " \e[7m dumps des flow dans le  switch\e[0m"
sleep 5
sudo ovs-ofctl dump-flows miniprojet
echo -e "\e[7m resultat : les paquets ip  sont routés vers le container correspondant à l'adresse ip destinataire et vers IDS \e[0m"
echo -e "\e[7m resultat : les paquet ARP sont forwardes sur tous les ports du switch\e[0m"
echo -e "\e[7mFIN DE LA CONFIGURATION INITIALE DU POC MINIPROJET\e[0m"
echo -e " \e[7m pour se connecter sur un  container < docker attach container> ctrl p ctrl  q pour sortir sans le tuer\e[0m"

