using System;
using System.Collections.Generic;
using TenzyBackend.Data.UserLogin;
using TenzyBackend.Models.UserModel;

namespace TenzyBackend.Core.Services.CustomerService
{
    public class CustomerService : ICustomerService
    {
        private readonly ILoginWriter _loginWriter;

        public CustomerService(ILoginWriter loginWriter)
        {
            _loginWriter = loginWriter;
        }

        public async Task<List<CustomerAdminModel>> GetAllCustomersAsync(
            int page, int pageSize, string? search)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 20;
            if (pageSize > 100) pageSize = 100;

            int offset = (page - 1) * pageSize;
            return await _loginWriter.GetAllCustomersAsync(pageSize, offset, search?.Trim());
        }

        public async Task<CustomerAdminModel?> GetCustomerByIdAsync(Guid userId)
        {
            if (userId == Guid.Empty)
                return null;

            return await _loginWriter.GetCustomerByIdAsync(userId);
        }
    }
}
