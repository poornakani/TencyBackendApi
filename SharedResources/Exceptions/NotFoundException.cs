using System;
using System.Collections.Generic;
using System.Net;
using System.Text;

namespace SharedResources.Exceptions
{
    public class NotFoundException : AppException
    {
        public NotFoundException(string message)
            : base(message, "NOT_FOUND", HttpStatusCode.NotFound)
        {
        }
    }
}
