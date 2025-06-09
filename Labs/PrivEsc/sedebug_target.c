#include <windows.h>

int main(int argc, char* argv[]) {
    if (argc < 2) return 1; // Need PID as argument
    DWORD pid = atoi(argv[1]);
    HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_SET_INFORMATION, FALSE, pid);
    if (!hProcess) return 1;
    HANDLE hToken;
    OpenProcessToken(hProcess, TOKEN_ADJUST_PRIVILEGES, &hToken);
    TOKEN_PRIVILEGES tp;
    LookupPrivilegeValue(NULL, SE_DEBUG_NAME, &tp.Privileges[0].Luid);
    tp.PrivilegeCount = 1;
    tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
    AdjustTokenPrivileges(hToken, FALSE, &tp, sizeof(tp), NULL, NULL);
    CloseHandle(hToken);
    CloseHandle(hProcess);
    return 0;
}