using Dapper;
using Microsoft.Extensions.Logging;
using SharedResources.Exceptions;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using TenzyBackend.DBContext;

namespace SharedResources.Infrastructure.Base
{
    public abstract class WriterBase<TEntity, TKey, TRepository> : RepositoryBase<TRepository>
        where TEntity : class
    {
        protected readonly DapperMethods _dapperPro;
        protected WriterBase(
            DapperMethods dapperPro,
            ILogger<TRepository> logger)
            : base(dapperPro, logger)
        {
            _dapperPro = dapperPro;
        }

        protected abstract string CreateProcedureName { get; }
        protected abstract string UpdateProcedureName { get; }
        protected abstract string DeleteProcedureName { get; }
        protected abstract string DeactiveProcedureName { get; }
        protected abstract string ActiveProcedureName { get; }
        protected abstract string IdParameterName { get; }

        protected abstract DynamicParameters BuildCreateParameters(TEntity entity);
        protected abstract DynamicParameters BuildUpdateParameters(TEntity entity);

        public virtual async Task<int> CreateAsync(TEntity entity)
        {
            return await ExecuteSafeAsync(async () =>
            {
                
                var parameters = BuildCreateParameters(entity);

                return await _dapperPro.InsertAsync<int>(
                    CreateProcedureName,
                    parameters,
                    commandType: CommandType.StoredProcedure);
            }, $"Create {typeof(TEntity).Name}");
        }

        public virtual async Task<bool> UpdateAsync(TEntity entity)
        {
            return await ExecuteSafeAsync(async () =>
            {
                
                var parameters = BuildUpdateParameters(entity);

                var rows = await _dapperPro.UpdateAsync<int>(
                    UpdateProcedureName,
                    parameters,
                    commandType: CommandType.StoredProcedure);

                if (rows == 0)
                    throw new NotFoundException($"{typeof(TEntity).Name} not found.");

                return true;
            }, $"Update {typeof(TEntity).Name}");
        }

        public virtual async Task<bool> DeleteAsync(TKey id)
        {
            return await ExecuteSafeAsync(async () =>
            {

                var parameters = new DynamicParameters();
                parameters.Add(IdParameterName, id);

                var rows = await _dapperPro.ExecuteAsync(
                    DeleteProcedureName,
                    parameters,
                    commandType: CommandType.StoredProcedure);

                if (rows == 0)
                    throw new NotFoundException($"{typeof(TEntity).Name} not found.");

                return true;
            }, $"Delete {typeof(TEntity).Name}");
        }

        public virtual async Task<bool> DeactiveAsync(TKey id)
        {
            return await ExecuteSafeAsync(async () =>
            {

                var parameters = new DynamicParameters();
                parameters.Add(IdParameterName, id);

                var rows = await _dapperPro.ExecuteAsync(
                    DeactiveProcedureName,
                    parameters,
                    commandType: CommandType.StoredProcedure);

                if (rows == 0)
                    throw new NotFoundException($"{typeof(TEntity).Name} not found.");

                return true;
            }, $"Delete {typeof(TEntity).Name}");
        }

        public virtual async Task<bool> ActiveAsync(TKey id)
        {
            return await ExecuteSafeAsync(async () =>
            {

                var parameters = new DynamicParameters();
                parameters.Add(IdParameterName, id);

                var rows = await _dapperPro.ExecuteAsync(
                    ActiveProcedureName,
                    parameters,
                    commandType: CommandType.StoredProcedure);

                if (rows == 0)
                    throw new NotFoundException($"{typeof(TEntity).Name} not found.");

                return true;
            }, $"Delete {typeof(TEntity).Name}");
        }
    }
}
