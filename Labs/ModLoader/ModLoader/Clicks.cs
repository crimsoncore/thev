using System;
using System.Runtime.InteropServices;
using System.Threading;

namespace ModLoader
{
    public static class MouseClickWait
    {
        [DllImport("user32.dll")] private static extern short GetAsyncKeyState(int vKey);
        public static void WaitForClicks(int minClicks = 5)
        {
            bool leftWasUp = true, rightWasUp = true;
            for (int count = 0; count < minClicks; Thread.Sleep(100))
            {
                short left = GetAsyncKeyState(1), right = GetAsyncKeyState(2);
                if ((left & 0x8000) != 0 && leftWasUp) { count++; leftWasUp = false; }
                else if ((left & 0x8000) == 0) leftWasUp = true;
                if ((right & 0x8000) != 0 && rightWasUp) { count++; rightWasUp = false; }
                else if ((right & 0x8000) == 0) rightWasUp = true;
            }
        }
    }
}