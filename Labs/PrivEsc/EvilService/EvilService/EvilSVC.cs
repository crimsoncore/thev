using System;
using System.Diagnostics;
using System.Net.NetworkInformation;
using System.ServiceProcess;
using System.Timers;

namespace EvilService
{
    public partial class EvilSVC : ServiceBase
    {
        private Timer timer;

        public EvilSVC()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            timer = new Timer();
            timer.Interval = 60000; // Ping every 60 seconds
            timer.Elapsed += new ElapsedEventHandler(this.OnTimer);
            timer.Start();
            EventLog.WriteEntry("EvilService started.");
        }

        protected override void OnStop()
        {
            timer.Stop();
            EventLog.WriteEntry("EvilService stopped.");
        }

        public void OnTimer(object sender, ElapsedEventArgs args)
        {
            Ping ping = new Ping();
            try
            {
                PingReply reply = ping.Send("1.1.1.1");
                if (reply.Status == IPStatus.Success)
                {
                    EventLog.WriteEntry("Ping to 1.1.1.1 successful: " + reply.RoundtripTime + " ms");
                }
                else
                {
                    EventLog.WriteEntry("Ping to 1.1.1.1 failed: " + reply.Status);
                }
            }
            catch (Exception ex)
            {
                EventLog.WriteEntry("Ping to 1.1.1.1 failed: " + ex.Message);
            }
        }
    }
}