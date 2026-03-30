using System;
using System.Collections.Generic;
using System.Text;

namespace TenzyBackend.Models.ApiResponseModels
{
    public class ApiResponseModel
    {
        public bool result { get; set; }
        public string? message { get; set; }
        public object? response { get; set; }
    }
}
