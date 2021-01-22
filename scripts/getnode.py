import requests
import sys
print (" identification de l'id openflow du switch et de l'id des ports '\n'")
odl_username = 'admin'
odl_password = 'admin'
odl_url = 'http://172.17.0.2:8181/restconf/operational/network-topology:network-topology'
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


