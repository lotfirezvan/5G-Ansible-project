# Ping test
docker exec oai-ext-dn ping -c 3 12.1.1.2 #Ping the UE from the external DN to verify connectivity. You should see successful ping responses if everything is set up correctly.
docker exec gnbsim ping -c 3 -I 12.1.1.2 google.com #Ping an external address from the UE to verify internet connectivity. You should see successful ping responses if everything is set up correctly.



  - name: Ping the UE from the External Data Network
    community.docker.docker_container_exec:
      container: oai-ext-dn
      command: ping -c 3 12.1.1.2
    register: ping_result
    become: no  # Your user usually has docker group permissions
  - name: Show the ping results
    ansible.builtin.debug:
      msg: "{{ ping_result.stdout_lines }}"


  - name: Test 5G Internet Connectivity from UE
    community.docker.docker_container_exec:
      container: gnbsim
      command: ping -c 3 -I 12.1.1.2 google.com
    register: ue_ping_result
    ignore_errors: yes
  - name: Print Ping Output to Console
    ansible.builtin.debug:
      var: ue_ping_result.stdout_lines

  - name: Start iperf3 Server in OAI-EXT-DN (Daemon Mode)
    community.docker.docker_container_exec:
      container: oai-ext-dn
      command: iperf3 -s -D
    register: iperf_server_result
  - name: Confirm iperf3 Server is Listening
    ansible.builtin.debug:
      msg: "iperf3 server is running in the background on oai-ext-dn"
    when: iperf_server_result.rc == 0
