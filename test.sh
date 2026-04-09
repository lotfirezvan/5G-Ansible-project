# Ping test
docker exec oai-ext-dn ping -c 3 12.1.1.2 #Ping the UE from the external DN to verify connectivity. You should see successful ping responses if everything is set up correctly.
docker exec gnbsim ping -c 3 -I 12.1.1.2 google.com #Ping an external address from the UE to verify internet connectivity. You should see successful ping responses if everything is set up correctly.
