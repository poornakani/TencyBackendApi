using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Models.ProductsModels
{
    public class BrandModel
    {
        
        public int BrandId { get; set; }

        public string Name { get; set; } = string.Empty;
        
        public string? BrandImage { get; set; }
        
        public DateTime CreateDate { get; set; }
       
        public DateTime? LastUpdated { get; set; }

        public bool IsActive { get; set; }
    }
}
