# Litterbox / Avred (Forensics)



# AVRed-Server

***On windows:***

```powershell
cd c:\git
git clone hhttps://github.com/dobin/avred-server.git
cd avred-server
pip install  -r requirements.txt
```

Edit the config.yaml file

```yaml
{
	"bind_ip": "0.0.0.",
	"port": 8001,
	"engine": "Amsi"
}
```

![image](./images/avred_server.jpg)

On your windows machine browse to the linke:

![image](./images/avred_server_chrome.jpg)


OPTIONALLY - Install as service with NSSM

<https://nssm.cc/ci/nssm-2.24-103-gdee49fc.zip>

```powershell
where python.exe
C:\Users\threatadmin\AppData\Local\Programs\Python\Python312\python.exe
C:\Users\threatadmin\AppData\Local\Microsoft\WindowsApps\python.exe
```

```powershell
nssm install AvredServer"C:\\Users\\threatadmin\\AppData\\Local\\Programs\\Python\\Python312\\python.exe" "C:\\git\\avred-server\\avred_server.py"
nssm set AvredTest AppDirectory "C:\\git\\avred-server\\"
nssm.exe start AvredServer
```

Download and install Radare2 on windows and add it to the path

```powershell
cd git
git clone https://github.com/dobin/avred.git
pip install -R requirements.txt
```

Edit the config.yaml

```yaml
server:
  Amsi: "http://10.0.0.8:8001/"
password: ""
hashCache: True
WebMaxFileSizeMb: 50
```

run a scan from commandline
```powershell
python3 avred.py -f app/upload/meterpreter.exe 
```



Run the (GUI) server (this is running on your KALI machine)
```bash
python3 avredweb.py
```

Browse to the server GUI (from windows or Kali)
http:\\10.0.0.7:5000

Install as a service with NSSM


-----

***On Kali***

1. Install *Radare*

```bash
sudo apt install radare2
```

2. Install *AVRed*
```bash
cd ~/Desktop
git clone https://github.com/dobin/avred.git
sudo chown -R Threatadmin:Threatadmin avred

```

edit the config.yaml and point it to the windows avred_server

```bash
cd ~/Desktop/avred
nano config.yaml
```

```yaml
server:
  Amsi: "http://10.0.0.8:8001/"
password: ""
hashCache: True
WebMaxFileSizeMb: 50
```

build AVRed

```bash
pip install setuptools
udo apt-get install python3-magic   
pip3 install --upgrade Flask-SQLAlchemy --break-system-ackages
pip3 install --upgrade -r requirements.txt --break-system-packages
```

run a scan from commandline
```bash
python3 avred.py -f app/upload/meterpreter.exe 
```



Run the (GUI) server (this is running on your KALI machine)
```bash
python3 avredweb.py
```

Browse to the server GUI (from windows or Kali)
http:\\10.0.0.7:5000