using System;
using System.Collections.Generic;
using System.Text;

namespace SharedResources.SharedModels
{
    public class ValidationErrorResponse : ErrorResponse
    {
        public Dictionary<string, string[]> Errors { get; set; } = new();
    }
}
