using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Models.ProductsModels
{
    public class ProductImageModel
    {
        public int ImageId { get; set; }
    
        public int ProductId { get; set; }
 
        public string ImageUrl { get; set; } = string.Empty;
        
        public bool IsPrimary { get; set; }
  
        public int SortOrder { get; set; }

        public DateTime CreateDate { get; set; }

        public bool IsActive { get; set; }
    }
}
