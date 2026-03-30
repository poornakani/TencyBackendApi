using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Core.Mapping
{
    public class MappingProfile : AutoMapper.Profile
    {
        public override string ProfileName => GetType().FullName;
    }
}
