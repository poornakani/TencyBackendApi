using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Core.Mapping
{
    public interface IObjectMapper
    {
        object Map(object source, Type sourceType, Type destinationType);

        D Map<D>(object source, Type sourceType);

        D Map<S, D>(S src);

    }
}
