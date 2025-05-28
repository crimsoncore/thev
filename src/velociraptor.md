# Velcoriraptor
```bash
mkdir ~/velociraptor_setup && cd ~/velociraptor_setup\n
wget -O velociraptor https://github.com/Velocidex/velociraptor/releases/download/v0.74/velociraptor-v0.74.1-linux-amd64\n
chmod +x velociraptor\n
./velociraptor config generate -i\n
./velociraptor debian server --config ./server.config.yaml\n
sudo dpkg -i velociraptor_server_0.74.1_amd64.deb
systemctl status velociraptor_server.service
sudo nano /etc/velociraptor/server.config.yaml
systemctl restart velociraptor_server.service
systemctl status velociraptor_server.service
```

Creating a service client (MSI)
<https://docs.velociraptor.app/docs/deployment/clients/#option-1-obtaining-the-client-config-from-the-gui>

check yaml config under `c:\program files\velociraptor`

![Screenshot](./images/veloci_pwsh.jpg)
![Screenshot](./images/veloci_param.jpg)
![Screenshot](./images/veloci_result.jpg)

Find files
![Screenshot](./images/veloci_files.jpg)
![Screenshot](./images/veloci_filesresult.jpg)