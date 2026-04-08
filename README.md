# 5G Core Ansible deployment  

This graduate course project was implemented with the goal to deploy a 5G core on low resources general purpose computer. 
Another major goal of this project was to evaluate the improvement that can be achieved by automating the deployment using tools like Ansible versus regular shell commands. 

## 📋Overview

An Ansible automation framework for deploying and testing a 5G network core using OpenAirInterface (OAI) with Docker. 
This project simplifies the provisioning of a complete 5G SA (Standalone) environment with the OAI and a gNB simulator.


This repository automates the deployment of an OpenAirInterface 5G Core Network along with supporting infrastructure including:
- **Docker** installation and configuration
- **Ansible** 
- **Python 3.9.18** setup via pyenv
- **OAI 5G Core Components : v2.2.0**: AMF, NRF, UPF, SMF
- **5G RAN Components**: gNB (Base Station), NR-UE (User Equipment)
- **Testing Tools**: iperf3 for throughput measurements, ping for connectivity tests
- **MySQL**: 8.0

## ⚠️ WARNING : This code is meant to be ran in a VM

## 📁 Project Structure
• **installAnsible.sh**  : Initial script to run in order to install Ansible on the current machine

• **DeployOAI.sh** : The main script to deploy the 5G core on the current machine using shell commands

• **DeployOAI.yaml**  : The main Ansible YAML to deploy the 5G core on the current machine using Ansible tasks

• **time_ansible.sh** : Script to run and time the DeployOAI.sh script

• **time_manual.sh** : Script to run and time the DeployOAI.yaml playbook

## 📊 What Gets Deployed
5G Core Network Services :

• AMF (Access and Mobility Management Function)

• NRF (Network Repository Function)

• UPF (User Plane Function)

• SMF (Session Management Function)

• External Data Network (EXT-DN) for simulations and generating traffic

RAN Components :

• gnbsim : A simulator of a gNB and an UE


## 📚 Deployment High Level Steps 

1. Installs Docker Engine and Compose
2. Sets up Python 3.9.18 via pyenv
3. Pulls OAI container images
4. Configures networking (IPv4 forwarding, iptables)
5. Deploys 5G Core Network (mini scenario)
6. Launches gNB simulator
7. Executes connectivity and throughput tests

## 📝 Notes
 • All operations requiring elevated privileges are marked with become: yes in the YAML file
 
 • The Ansible deployment is designed for local execution but can be adapted for remote hosts
 
 • Complete logs are saved for troubleshooting and analysis
 
 • The scenario uses OAI's "mini" configuration (Scenario 2) with gnbsim for simplicity

## 📄 License
This project is provided as-is. Please ensure compliance with OAI licensing requirements.

## 🚀 Quick Start

### Prerequisites
- Ubuntu 22.04 (Jammy) or compatible Linux distribution VM
- Ansible installed on the control machine
- SSH access to target hosts (or use localhost by default)
- Around 8GB RAM and 30GB disk space recommended

### Installation

1. **Clone the repo** :
```bash
git clone https://github.com/lotfirezvan/5G-Ansible-project.git
```
2. **Install Ansible** (if not already installed):
```bash
chmod +x installAnsible.sh
./installAnsible.sh
```
3.  **Run and Time Manual Deployment** :
```bash
chmod +x time_manual.sh
./time_manual.sh
```
3. **Run and Time Ansible Deployment** :
```bash
chmod +x time_ansible.sh
./time_ansible.sh
```
