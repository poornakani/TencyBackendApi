using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Entity.ProductsEntity
{
    public class ProductConcernEntity
    {
        [Column("productid", Order = 0)]
        public int ProductId { get; set; }

        [Column("concernID", Order = 1)]
        public int ConcernId { get; set; }

        public virtual ProductCatalogEntity? ProductCatalog { get; set; }

        public virtual ConcernTypeEntity? ConcernType { get; set; }
    }
}
