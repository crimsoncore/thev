using System.ServiceProcess;

namespace EvilService
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        static void Main()
        {
            ServiceBase[] ServicesToRun;
            ServicesToRun = new ServiceBase[]
            {
                new EvilService.EvilSVC()
            };
            ServiceBase.Run(ServicesToRun);
        }
    }
}
