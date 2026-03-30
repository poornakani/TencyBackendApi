using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Entity.ProductsEntity
{
    public class ProductInventoryEntity
    {
        [Column("productid")]
        public int ProductId { get; set; }

        [Required]
        [Column("stock")]
        public int Stock { get; set; }

        [Required]
        [Column("LastStockUpdateUTC")]
        public DateTime LastStockUpdateUtc { get; set; }

        public virtual ProductCatalogEntity? ProductCatalog { get; set; }
    }
}
