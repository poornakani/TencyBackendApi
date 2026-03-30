
using AutoMapper;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Core.Mapping;
using TenzyBackend.DBContext;

namespace TenzyBackend.Core.Extentions
{
    public static class RegistrationConfig
    {
        public static void RegisterClassess(this IServiceCollection serviceCollection) 
        {
            serviceCollection.AddSingleton<IObjectMapper, ObjectMapper>();
            serviceCollection.AddSingleton<DapperContext>();
            serviceCollection.AddScoped<IDapperMethods, DapperMethods>();


           
        }
    }

}
