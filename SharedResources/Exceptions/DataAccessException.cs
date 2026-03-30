using System;
using System.Collections.Generic;
using System.Net;
using System.Text;

namespace SharedResources.Exceptions
{
    public class DataAccessException : AppException
    {
        public string Operation { get; }

        public DataAccessException(string operation, string message, Exception? innerException = null)
            : base(message, "DATA_ACCESS_ERROR", HttpStatusCode.InternalServerError, innerException)
        {
            Operation = operation;
        }
    }
}
