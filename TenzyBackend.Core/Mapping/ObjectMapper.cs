using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Core.Mapping
{
    public class ObjectMapper : IObjectMapper
    {
        private readonly AutoMapper.IMapper _mapper;
        public ObjectMapper(AutoMapper.IMapper mapper)
        {
            _mapper = mapper;
        }
        public D Map<S, D>(S src)
        {

            var result = _mapper.Map<D>(src);
            return result;
        }

        public object Map(object source, Type sourceType, Type destinationType)
        {
            var result = _mapper.Map(source, sourceType, destinationType);
            return result;
        }

        public D Map<D>(object source, Type sourceType) => (D)Map(source, sourceType, typeof(D));
    }
}
