using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ConcernType
{
    public interface IConcernTypeWriter
    {
        Task<int> CreateAsync(ConcernTypeEntity concernentity);
        Task<bool> UpdateAsync(ConcernTypeEntity concernentity);
        Task<bool> DeactiveAsync(int concernID);
        Task<bool> ActiveAsync(int concernID);
    }
}
