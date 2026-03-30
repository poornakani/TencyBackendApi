using System;
using System.Collections.Generic;
using System.Text;

namespace SharedResources.SharedModels
{
    public class ErrorResponse
    {
        public bool Success { get; set; } = false;
        public string Message { get; set; } = string.Empty;
        public string ErrorCode { get; set; } = string.Empty;
        public int StatusCode { get; set; }
        public string? TraceId { get; set; }
    }
}
