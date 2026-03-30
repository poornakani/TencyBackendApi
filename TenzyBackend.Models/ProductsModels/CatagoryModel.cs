using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Models.ProductsModels
{
    public class CatagoryModel
    {
        public int CategoryId { get; set; }

        public string CategoryType { get; set; } = string.Empty;

        public bool IsActive { get; set; }
    }
}
