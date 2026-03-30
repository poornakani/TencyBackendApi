using System;
using System.Collections.Generic;
using System.Net;
using System.Text;

namespace SharedResources.Exceptions
{
    public class UnauthorizedAppException : AppException
    {
        public UnauthorizedAppException(string message = "You are not authorized.")
            : base(message, "UNAUTHORIZED", HttpStatusCode.Unauthorized)
        {
        }
    }
}
