using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.DBContext
{
    public interface IDatabaseSettings
    {
        public string ConnectionString { get; }

        public string DatabaseName { get; }
    }
}
