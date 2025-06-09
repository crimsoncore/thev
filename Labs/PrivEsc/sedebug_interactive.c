#include <windows.h>

int main() {
    HANDLE hToken;
    OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, &hToken);
    TOKEN_PRIVILEGES tp;
    LookupPrivilegeValue(NULL, SE_DEBUG_NAME, &tp.Privileges[0].Luid);
    tp.PrivilegeCount = 1;
    tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
    AdjustTokenPrivileges(hToken, FALSE, &tp, sizeof(tp), NULL, NULL);
    
    STARTUPINFO si = {sizeof(si)};
    si.dwFlags = STARTF_USESHOWWINDOW;  // Show the window
    si.wShowWindow = SW_SHOW;          // Make it visible
    PROCESS_INFORMATION pi;
    
    CreateProcess(NULL, "cmd.exe", NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi);
    
    // Wait for the cmd to finish (optional, for interactive use you might want to remove this)
    WaitForSingleObject(pi.hProcess, INFINITE);
    
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    CloseHandle(hToken);
    
    return 0;
}