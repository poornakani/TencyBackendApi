using Microsoft.Extensions.Logging;
using SharedResources.Exceptions;
using SharedResources.Infrastructure;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.DBContext;

namespace SharedResources.Infrastructure.Base
{
    public abstract class RepositoryBase<TRepository>
    {
        protected readonly DapperMethods _dapperPro;
        protected readonly ILogger<TRepository> Logger;

        protected RepositoryBase(
           DapperMethods dapperPro,
            ILogger<TRepository> logger)
        {
            _dapperPro = dapperPro;
            Logger = logger;
        }

        protected async Task<T> ExecuteSafeAsync<T>(
            Func<Task<T>> action,
            string operation)
        {
            try
            {
                return await action();
            }
            catch (Exception ex) when (ex is not AppException)
            {
                throw DataLayerExceptionHelper.Handle(ex, operation, Logger);
            }
        }

        protected async Task ExecuteSafeAsync(
            Func<Task> action,
            string operation)
        {
            try
            {
                await action();
            }
            catch (Exception ex) when (ex is not AppException)
            {
                throw DataLayerExceptionHelper.Handle(ex, operation, Logger);
            }
        }
    }
}
