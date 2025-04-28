# Litterbox / Avred (Forensics)

## 1. Qu1ckSc0pe
<https://github.com/CYB3RMX/Qu1cksc0pe>

![image](./images/litter_quick.jpg)

## 2. Detect it Easy

<https://github.com/horsicq/Detect-It-Easy/>

![image](./images/litter_DIE.jpg)

## 3. Litterbox

```powershell
cd git
git clone https://github.com/BlackSnufkin/LitterBox.git
cd LitterBox
pip install -r requirements.txt
```

Run the server manually:

```powershell
python litterbox.py
```
Browse to the server GUI (from windows or Kali)
<http:\\localhost:1337>

![image](./images/litterbox.jpg)

Or install as a service:

```
nssm install Litterbox "C:\\Users\\threatadmin\\AppData\\Local\\Programs\\Python\\Python312\\python.exe" "C:\\git\\litterbox\\litterbox.py"
nssm set Litterbox AppDirectory "C:\\git\\litterbox\\"
nssm.exe start litterbox
```

----
