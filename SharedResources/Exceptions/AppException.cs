using System;
using System.Collections.Generic;
using System.Net;
using System.Text;

namespace SharedResources.Exceptions
{
    public class AppException :Exception
    {
        public HttpStatusCode StatusCode { get; }
        public string ErrorCode { get; }

        protected AppException(
            string message,
            string errorCode,
            HttpStatusCode statusCode,
            Exception? innerException = null)
            : base(message, innerException)
        {
            ErrorCode = errorCode;
            StatusCode = statusCode;
        }
}
}
