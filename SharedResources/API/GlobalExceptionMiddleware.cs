using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using SharedResources.Exceptions;
using SharedResources.SharedModels;
using System;
using System.Collections.Generic;
using System.Net;
using System.Text;
using System.Text.Json;

namespace SharedResources.API
{
    
    public class GlobalExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<GlobalExceptionMiddleware> _logger;

        public GlobalExceptionMiddleware(
            RequestDelegate next,
            ILogger<GlobalExceptionMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (ValidationException ex)
            {
                _logger.LogWarning(ex, "Validation error occurred.");
                await WriteValidationResponseAsync(context, ex);
            }
            catch (AppException ex)
            {
                _logger.LogWarning(ex, "Application exception occurred.");
                await WriteAppExceptionResponseAsync(context, ex);
            }
            catch (ArgumentNullException ex)
            {
                _logger.LogWarning(ex, "Argument null exception occurred.");
                await WriteGenericResponseAsync(
                    context,
                    HttpStatusCode.BadRequest,
                    "ARGUMENT_NULL",
                    ex.Message);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Argument exception occurred.");
                await WriteGenericResponseAsync(
                    context,
                    HttpStatusCode.BadRequest,
                    "ARGUMENT_ERROR",
                    ex.Message);
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning(ex, "Key not found exception occurred.");
                await WriteGenericResponseAsync(
                    context,
                    HttpStatusCode.NotFound,
                    "KEY_NOT_FOUND",
                    ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unhandled exception occurred.");
                await WriteGenericResponseAsync(
                    context,
                    HttpStatusCode.InternalServerError,
                    "INTERNAL_SERVER_ERROR",
                    "An unexpected error occurred.");
            }
        }

        private static async Task WriteAppExceptionResponseAsync(HttpContext context, AppException exception)
        {
            context.Response.ContentType = "application/json";
            context.Response.StatusCode = (int)exception.StatusCode;

            var response = new ErrorResponse
            {
                Success = false,
                Message = exception.Message,
                ErrorCode = exception.ErrorCode,
                StatusCode = (int)exception.StatusCode,
                TraceId = context.TraceIdentifier
            };

            await context.Response.WriteAsync(JsonSerializer.Serialize(response));
        }

        private static async Task WriteValidationResponseAsync(HttpContext context, ValidationException exception)
        {
            context.Response.ContentType = "application/json";
            context.Response.StatusCode = (int)HttpStatusCode.BadRequest;

            var response = new ValidationErrorResponse
            {
                Success = false,
                Message = exception.Message,
                ErrorCode = exception.ErrorCode,
                StatusCode = (int)HttpStatusCode.BadRequest,
                TraceId = context.TraceIdentifier,
                Errors = exception.Errors
            };

            await context.Response.WriteAsync(JsonSerializer.Serialize(response));
        }

        private static async Task WriteGenericResponseAsync(
            HttpContext context,
            HttpStatusCode statusCode,
            string errorCode,
            string message)
        {
            context.Response.ContentType = "application/json";
            context.Response.StatusCode = (int)statusCode;

            var response = new ErrorResponse
            {
                Success = false,
                Message = message,
                ErrorCode = errorCode,
                StatusCode = (int)statusCode,
                TraceId = context.TraceIdentifier
            };

            await context.Response.WriteAsync(JsonSerializer.Serialize(response));
        }
    }
    
}
