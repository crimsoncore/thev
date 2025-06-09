using System;
using System.Runtime.InteropServices;


namespace ModLoader
{
    public static class AmsiTest
    {
        [DllImport("amsi.dll")] private static extern int AmsiInitialize([MarshalAs(UnmanagedType.LPWStr)] string appName, out IntPtr amsiContext);
        [DllImport("amsi.dll")] private static extern int AmsiOpenSession(IntPtr amsiContext, out IntPtr session);
        [DllImport("amsi.dll")] private static extern int AmsiScanString(IntPtr amsiContext, [MarshalAs(UnmanagedType.LPWStr)] string str, [MarshalAs(UnmanagedType.LPWStr)] string contentName, IntPtr session, out int result);
        [DllImport("amsi.dll")] private static extern void AmsiCloseSession(IntPtr amsiContext, IntPtr session);
        [DllImport("amsi.dll")] private static extern void AmsiUninitialize(IntPtr amsiContext);

        public static bool TestAmsi()
        {
            const string eicar = "X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*";
            if (AmsiInitialize("ModLoader", out IntPtr ctx) != 0) return false;
            bool result = AmsiOpenSession(ctx, out IntPtr session) == 0 && AmsiScanString(ctx, eicar, "EicarTest", session, out int res) == 0 && res >= 32768;
            AmsiCloseSession(ctx, session);
            AmsiUninitialize(ctx);
            return result;
        }
    }
}
