using Dapper;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using TenzyBackend.DBContext;

namespace SharedResources.Infrastructure.Base
{
    public abstract class ReaderBase<TEntity, TKey, TRepository> : RepositoryBase<TRepository> where TEntity : class
    {
        protected readonly DapperMethods _dapperPro;

        protected ReaderBase(DapperMethods dapperPro, ILogger<TRepository> logger) : base(dapperPro, logger)
        {
            _dapperPro = dapperPro;
        }

        protected abstract string GetByIdProcedureName { get; }
        protected abstract string GetAllProcedureName { get; }
        protected abstract string IdParameterName { get; }

        public virtual async Task<TEntity?> GetByIdAsync(TKey id)
        {
            return await ExecuteSafeAsync(async () =>
            {
                var parameters = new DynamicParameters();
                parameters.Add(IdParameterName, id);

                return await _dapperPro.GetAsync<TEntity>(
                    GetByIdProcedureName,
                    parameters,
                    commandType: CommandType.StoredProcedure);
            }, $"Get {typeof(TEntity).Name} By Id");
        }

        public virtual async Task<List<TEntity>> GetAllAsync()
        {
            return await ExecuteSafeAsync(async () =>
            {
                var result = await _dapperPro.GetAllAsync<TEntity>(
                        GetAllProcedureName,
                        commandType: CommandType.StoredProcedure);

                return result.ToList();
            }, $"Get All {typeof(TEntity).Name}");
        }
    }
}
