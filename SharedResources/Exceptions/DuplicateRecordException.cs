using System;
using System.Collections.Generic;
using System.Net;
using System.Text;

namespace SharedResources.Exceptions
{
    public class DuplicateRecordException : AppException
    {
        public DuplicateRecordException(string message, Exception? innerException = null)
            : base(message, "DUPLICATE_RECORD", HttpStatusCode.Conflict, innerException)
        {
        }
    }
}
