using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;
using System.Text.Json.Serialization;

namespace TenzyBackend.Models.ProductsModels
{
    public class ProductFAQModel
    {
        [Key]
        [Column("FAQId")]
        [JsonPropertyName("faqId")]
        public int FAQId { get; set; }

        [Required]
        [Column("productid")]
        public int ProductId { get; set; }

        [Required]
        [Column("Question")]
        public string Question { get; set; } = string.Empty;

        [Required]
        [Column("Answer")]
        public string Answer { get; set; } = string.Empty;

        [Required]
        [Column("createdUTC")]
        public DateTime CreatedUtc { get; set; }

        public bool IsActive { get; set; }
    }
}
