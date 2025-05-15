#!/bin/bash
sudo systemctl stop wazuh-indexer
sudo systemctl disable wazuh-indexer
sudo systemctl stop wazuh-dashboard
sudo systemctl disable wazuh-dashboard

