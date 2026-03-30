using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Entity.ProductsEntity
{
    public class PaymentTypeEntity
    {
        [Key]
        [Column("PaymentTypeId")]
        public int PaymentTypeId { get; set; }

        [Required]
        [Column("PaymentType")]
        public string Name { get; set; } = string.Empty;

        public bool IsActive { get; set; }
    }
}
