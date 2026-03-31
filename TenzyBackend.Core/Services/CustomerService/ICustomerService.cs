using System;
using System.Collections.Generic;
using TenzyBackend.Models.UserModel;

namespace TenzyBackend.Core.Services.CustomerService
{
    public interface ICustomerService
    {
        Task<List<CustomerAdminModel>> GetAllCustomersAsync(int page, int pageSize, string? search);
        Task<CustomerAdminModel?> GetCustomerByIdAsync(Guid userId);
    }
}
