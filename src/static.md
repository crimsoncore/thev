# Static Analysis

strings, threatcheck

# YARA


Let's first install YARA support in VSCODE

![Screenshot](./images/yaracode.jpg)

```yara
rule PE_Detected
{
    meta:
        description = "Detects 'MZ header'"
        author = "Peter Girnus"
            web = "https://www.petergirnus.com/blog"

    condition:
        uint16(0) == 0x5a4d
}
```

<mark>Marked text</mark>

Run strings on NativeDump
HxD or XXD on NativeDump.exe

LitterBox

threatcheck/GoCheck on rubeus (make sure defender execption is off for the folder both files are located)

Check output threatcheck/gocheck

erase with 0x00's

use visual studio find all/replace all (match word)