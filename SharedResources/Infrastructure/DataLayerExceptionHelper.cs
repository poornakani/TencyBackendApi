using Microsoft.Extensions.Logging;
using SharedResources.Exceptions;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;

namespace SharedResources.Infrastructure
{
    public static class DataLayerExceptionHelper
    {
        public static Exception Handle(Exception exception, string operation, ILogger logger)
        {
            logger.LogError(exception, "Database error occurred during operation: {Operation}", operation);

            if (exception is SqlException sqlEx)
            {
                return sqlEx.Number switch
                {
                    2627 => new DuplicateRecordException("A record with the same value already exists.", sqlEx),
                    2601 => new DuplicateRecordException("A unique constraint violation occurred.", sqlEx),
                    547 => new DataAccessException(operation, "This action failed because the record is related to other data.", sqlEx),
                    -2 => new DataAccessException(operation, "The database operation timed out.", sqlEx),
                    4060 => new DataAccessException(operation, "Unable to open the database.", sqlEx),
                    18456 => new DataAccessException(operation, "Database authentication failed.", sqlEx),
                    53 => new DataAccessException(operation, "Unable to connect to the database server.", sqlEx),
                    _ => new DataAccessException(operation, "A database error occurred.", sqlEx)
                };
            }

            if (exception is TimeoutException timeoutEx)
            {
                return new DataAccessException(operation, "The operation timed out.", timeoutEx);
            }

            if (exception is InvalidOperationException invalidOpEx)
            {
                return new DataAccessException(operation, "An invalid database operation occurred.", invalidOpEx);
            }

            return new DataAccessException(operation, "An unexpected data access error occurred.", exception);
        }
    }
}
