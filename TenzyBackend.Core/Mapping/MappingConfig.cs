using AutoMapper;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.Enums;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Entity.UserEntity;
using TenzyBackend.Models.Enums;
using TenzyBackend.Models.ProductsModels;
using TenzyBackend.Models.UserModel;

namespace TenzyBackend.Core.Mapping
{
    public static class MappingConfig
    {
        public static void AddMapping(this Microsoft.Extensions.DependencyInjection.IServiceCollection serviceCollection)
        {

            var mapping = new MapperConfiguration(x =>
            {
                x.CreateMap<UsersModel, UsersEntity>().ReverseMap();
                x.CreateMap<UserRoleEnumsModel, UserRoleEnumsEntity>().ReverseMap();
                x.CreateMap<BrandModel, BrandEntity>().ReverseMap();
                x.CreateMap<CatagoryModel, CategoryEntity>().ReverseMap();
                x.CreateMap<ConcernTypeModel,ConcernTypeEntity>().ReverseMap();
                x.CreateMap<PaymentTypeModel, PaymentTypeEntity>().ReverseMap();
                x.CreateMap<ProductFAQModel, ProductFAQEntity>().ReverseMap();
                x.CreateMap<ProductImageModel, ProductImageEntity>().ReverseMap();
                






            });
            var mapper = mapping.CreateMapper();

            serviceCollection.AddSingleton(mapper);
            try
            {
                mapper.ConfigurationProvider.AssertConfigurationIsValid();
            }
            catch (Exception)
            {
            }
        }
    }
}
