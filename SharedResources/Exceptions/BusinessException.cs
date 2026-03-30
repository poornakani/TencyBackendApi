using System;
using System.Collections.Generic;
using System.Net;
using System.Text;

namespace SharedResources.Exceptions
{
    public class BusinessException : AppException
    {
        public BusinessException(string message)
            : base(message, "BUSINESS_RULE_ERROR", HttpStatusCode.BadRequest)
        {
        }
    }
}
