using System;
using System.Diagnostics;
using System.Net.NetworkInformation;
using System.ServiceProcess;
using System.Timers;

namespace VulnService
{
    public partial class Service1 : ServiceBase
    {
        private Timer timer;

        public Service1()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            timer = new Timer();
            timer.Interval = 5000; // Ping every 5 seconds
            timer.Elapsed += new ElapsedEventHandler(this.OnTimer);
            timer.Start();
            EventLog.WriteEntry("PingService started.");
        }

        protected override void OnStop()
        {
            timer.Stop();
            EventLog.WriteEntry("PingService stopped.");
        }

        public void OnTimer(object sender, ElapsedEventArgs args)
        {
            Ping ping = new Ping();
            try
            {
                PingReply reply = ping.Send("8.8.8.8");
                if (reply.Status == IPStatus.Success)
                {
                    EventLog.WriteEntry("Ping to 8.8.8.8 successful: " + reply.RoundtripTime + " ms");
                }
                else
                {
                    EventLog.WriteEntry("Ping to 8.8.8.8 failed: " + reply.Status);
                }
            }
            catch (Exception ex)
            {
                EventLog.WriteEntry("Ping to 8.8.8.8 failed: " + ex.Message);
            }
        }
    }
}