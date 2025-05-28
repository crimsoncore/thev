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