using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.DBContext
{
    public class DatabaseSettingsConfig
    {
        public string? ConnectionString { get; set; }
        public string? DatabaseName { get; set; }
    }
}
