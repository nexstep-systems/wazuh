resource "lxd_instance" "wazuh" {
  name     = "wazuh"
  image    = "ubuntu2204"
  profiles = ["wazuh"]

  limits = {
    cpu    = "4"
    memory = "8GB"
  }

  config = {
    "user.user-data" = <<EOT
#cloud-config
package_update: true
package_upgrade: true
packages:
  - curl
  - apt-transport-https
  - gnupg
  - lsb-release

write_files:
  - path: /root/install-wazuh.sh
    permissions: "0755"
    content: |
      #!/bin/bash
      echo "Starting Wazuh installation..." > /var/log/wazuh_install.log 2>&1
      curl -s https://packages.wazuh.com/4.11/wazuh-install.sh -o /tmp/wazuh-install.sh >> /var/log/wazuh_install.log 2>&1
      if [ $? -ne 0 ]; then
        echo "Failed to download wazuh-install.sh" >> /var/log/wazuh_install.log 2>&1
        exit 1
      fi
      bash /tmp/wazuh-install.sh -a >> /var/log/wazuh_install.log 2>&1
      if [ $? -eq 0 ]; then
        echo "Wazuh installation completed successfully" >> /var/log/wazuh_install.log 2>&1
      else
        echo "Wazuh installation failed" >> /var/log/wazuh_install.log 2>&1
      fi

  - path: /etc/systemd/system/wazuh-install.service
    permissions: "0644"
    content: |
      [Unit]
      Description=Wazuh Installation Service
      After=network-online.target
      Wants=network-online.target

      [Service]
      Type=oneshot
      ExecStart=/root/install-wazuh.sh
      RemainAfterExit=yes
      TimeoutSec=1800

      [Install]
      WantedBy=multi-user.target

runcmd:
  - mkdir -p /var/log
  - systemctl daemon-reload
  - systemctl enable wazuh-install.service
  - systemctl start wazuh-install.service
EOT
  }
}
