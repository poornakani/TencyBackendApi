using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Entity.ProductsEntity
{
    public class ProductPaymentOption
    {
        [Column("productid", Order = 0)]
        public int ProductId { get; set; }

        [Column("PaymentTypeId", Order = 1)]
        public int PaymentTypeId { get; set; }

        [Column("instalment")]
        public int? Instalment { get; set; }

        public virtual ProductCatalogEntity? ProductCatalog { get; set; }

        public virtual PaymentTypeEntity? PaymentType { get; set; }
    }
}
