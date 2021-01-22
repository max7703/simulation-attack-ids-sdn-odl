DESCRIPTION DU REPO

dossier scripts contient les shell script et python script :

	createminiprojet.sh :RAZ  et création  la topologie complète 
		initialisation du reseau OVS miniprojet , creation des containers, attachement des containers au réseau 
		activation du protocol open_flow sur le switch, connexion au controleur, configuration initiale des flows
		commande : sudo ./createminiprojet.sh
		
	cleanminiprojet.sh:  
		RAZ  de la topologie OVS et Docker, inclut dans createmniprojet.sh
		commande sudo ./cleanminiprojet.sh

	initswitchb.py : programmation de  flows
		 programme python utilisé dans createminiprojet.sh pour envoyer les flows au controleur via l'interface RESCONF
	 	commande: sudo python3 initswitchb.py <id_fichier_flow1>  <id_fichier_flow2> <id_fichier_flown>
		ou <id_fichier_flow> correspond à l'id du fichier fl<id>.json dans le repertoire flow

	 getnode.py:
		programme python permettant de recupérer l'id openflow du switch
		commande sudo python3 ./getnode.py

	 putflow.py:
		programme python permettant d'envoyer un flow au controleur via l'interface RESCONF
		commande sudo python3 ./getnode.py

	 ftpthreat.sh:
		Parsing des logs de Snort, prend le dernier fichier de log, les 30 dernieres lignes
		Recupere l'ip à bannir si plus de 3 tentatives de connexion raté et envoie la requete vers l'API d'ODL
		commande sudo ./ftpthreat.sh

	 snortruleftp.txt:
		Fichier texte contenant la regle Snort pour generer des alertes en cas d'erreur de login FTP

Dossier flow: 
	contient les fichiers json de configuration initiale des flows envoyés au controleur dans le BODY des requetes HTTP/REST   
	l'id des fichier doit correspondre à l'id des flow openflow

PREREQUIS
	OPENVSWITCH,OVS-DOCKER,DOCKER  doivent etre installés dans le serveur (generalement installé dans /usr/bin) 

