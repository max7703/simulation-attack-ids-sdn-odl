import requests
import sys
import json
def putflow(ip,id_node,id_flow,fic_flow):
	print("id cookie:0x",hex(int(id_flow)))

#ouverture et lecture du fichier flow
	try:
		fic_flow =  open(fic_flow,"r")
		flow = fic_flow.read()
		fic_flow.close()
	except Exception as e:
        	print("problème à l'ouverture ou a la lecture du fichier flow", e.__class__)
        	quit()
	convflow=json.loads(flow)
	odl_username = 'admin'
	odl_password = 'admin'
	odl_url = "http://{}:8181/restconf/config/opendaylight-inventory:nodes/node/openflow:{}/table/0/flow/{}".format(ip,id_node,id_flow)
	print("URL du flow=",odl_url) 
	try:
		response = requests.put(odl_url, auth=(odl_username, odl_password),json=convflow)
	except Exception as e:
		print("erreur!", e.__class__, "dans l'URL")
		quit()
	print("reponse controleur",response,'\n')

def idnode(ip):
	
	print (" identification de l'id openflow du switch et de l'id des ports '\n'")
	odl_username = 'admin'
	odl_password = 'admin'
	odl_url = "http://{}:8181/restconf/operational/network-topology:network-topology".format(ip)
	print("URL toplogy",odl_url)
	try:
		response = requests.get(odl_url, auth=(odl_username, odl_password))
	except Exception as e:
		print("erreur!", e.__class__, "dans l'URL")
		quit()
	if str(response)=="<Response [200]>":
		print ( str(response), " ok le controleur repond")
	else :
		print ( str(response), " ko inutile d'aller plus loin")
		quit()
	nodes= response.json()['network-topology']['topology'] 
#print(nodes)
	try:
		for topology in  nodes :
			print("id topologie:",topology['topology-id'])
			for sw in topology['node']:
				sub_id_node= sw['node-id'][9:len(sw['node-id'])]
				print("id openflow du switch :",sub_id_node)
				for port in sw['termination-point']:
					port_id=port['tp-id'][port['tp-id'].rfind(":")+1:len(port['tp-id'])]
					print(" port  du switch id ",port_id)
	except Exception as e:
		print("impossible de recuperer la topologie",'\n',"le controleur n'est probablement pas correctement connecté au swith",e.__class__)

	return(sub_id_node)
#programme principal
# recuperation de l'id openflow du switch
ip=sys.argv[1]
fic_flow=sys.argv[2]
id_flow=sys.argv[3]
id_nodes=idnode(ip)
print("lancement configuration  du switch :{}".format(id_nodes))
#contruction du nom de fichier fl *.json, * etant id du fichier passé en argument
#l'id du flow openflow a passer dans l'URL RESTCONF = l'id du fichier flow
#le numero de cookie = numero de l'id du flow openflow
# les fichier json qui contiennent les flow doivent etre coherents avec ces règles
print("lancement du fichier flow:{} ".format(fic_flow))
print("id flow:{} ".format(id_flow))
putflow(ip,id_nodes,id_flow,fic_flow)
