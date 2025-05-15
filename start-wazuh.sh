#!/bin/bash
sudo systemctl enable wazuh-indexer
sudo systemctl start wazuh-indexer
sudo systemctl enable wazuh-dashboard
sudo systemctl start wazuh-dashboard


