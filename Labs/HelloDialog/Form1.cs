using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace HelloDialog
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            string message = "Simple MessageBox";
            string title = "Title";
            MessageBox.Show(message, title);
        }
    }
}
