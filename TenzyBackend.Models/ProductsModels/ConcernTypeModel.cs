using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace TenzyBackend.Models.ProductsModels
{
    public class ConcernTypeModel
    {
        public int ConcernTypeId { get; set; }
        public string Name { get; set; } = string.Empty;   
        public string Description { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }
}
