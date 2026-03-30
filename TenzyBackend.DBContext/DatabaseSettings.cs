using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.DBContext
{
    public class DatabaseSettings : IDatabaseSettings
    {
        public string ConnectionString { get; }
        public string DatabaseName { get; }
        public DatabaseSettings(DatabaseSettingsConfig config)
        {
            ConnectionString = config.ConnectionString;
            DatabaseName = config.DatabaseName;
        }
    }
}
