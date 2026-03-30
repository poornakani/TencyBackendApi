using System;
using System.Collections.Generic;
using System.Net;
using System.Text;

namespace SharedResources.Exceptions
{
    public class ForbiddenAppException : AppException
    {
        public ForbiddenAppException(string message = "You do not have permission to perform this action.")
            : base(message, "FORBIDDEN", HttpStatusCode.Forbidden)
        {
        }
    }
}
