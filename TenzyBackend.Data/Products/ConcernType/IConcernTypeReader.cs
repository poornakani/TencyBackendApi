using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.ProductsEntity;

namespace TenzyBackend.Data.Products.ConcernType
{
    public interface IConcernTypeReader
    {
        Task<ConcernTypeEntity?> GetByIdAsync(int catId);
        Task<List<ConcernTypeEntity>> GetAllAsync();
    }
}
