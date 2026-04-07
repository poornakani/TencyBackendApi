using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Entity.ProductsEntity
{
    public class ConcernTypeEntity
    {
        [Key]
        [Column("ConcernTypeId")]
        public int ConcernTypeId { get; set; }

        [Required]
        [Column("ConcernType")]
        public string Name { get; set; } = string.Empty;

        [Required]
        [Column("description")]
        public string Description { get; set; } = string.Empty;

        public bool IsActive { get; set; }
        public string? CategoryIdsCsv { get; set; }
        public string? CategoryNamesCsv { get; set; }
    }
}
