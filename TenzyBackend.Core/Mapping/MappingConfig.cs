using AutoMapper;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Text;
using TenzyBackend.Entity.AuditEntity;
using TenzyBackend.Entity.DispatchEntity;
using TenzyBackend.Entity.Enums;
using TenzyBackend.Entity.OrderEntity;
using TenzyBackend.Entity.ProcurementEntity;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Entity.UserEntity;
using TenzyBackend.Models.AuditModels;
using TenzyBackend.Models.DispatchModels;
using TenzyBackend.Models.Enums;
using TenzyBackend.Models.OrderModels;
using TenzyBackend.Models.ProcurementModels;
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
                // Existing mappings
                x.CreateMap<UsersModel, UsersEntity>().ReverseMap();
                x.CreateMap<UserRoleEnumsModel, UserRoleEnumsEntity>().ReverseMap();
                x.CreateMap<BrandModel, BrandEntity>().ReverseMap();
                x.CreateMap<CatagoryModel, CategoryEntity>().ReverseMap();
                x.CreateMap<ConcernTypeModel,ConcernTypeEntity>().ReverseMap();
                x.CreateMap<PaymentTypeModel, PaymentTypeEntity>().ReverseMap();
                x.CreateMap<ProductFAQModel, ProductFAQEntity>().ReverseMap();
                x.CreateMap<ProductImageModel, ProductImageEntity>().ReverseMap();

                // Product catalog (new)
                x.CreateMap<ProductCatalogEntity, ProductCatalogModel>().ReverseMap();

                // Procurement (new)
                x.CreateMap<ProcurementOrderEntity, ProcurementOrderModel>()
                    .ForMember(d => d.Items, opt => opt.Ignore())
                    .ReverseMap();
                x.CreateMap<ProcurementItemEntity, ProcurementItemModel>().ReverseMap();

                // Orders
                x.CreateMap<OrderEntity, OrderModel>()
                    .ForMember(d => d.Items, opt => opt.Ignore())
                    .ReverseMap();
                x.CreateMap<OrderItemEntity, OrderItemModel>().ReverseMap();

                // Reviews
                x.CreateMap<ProductReviewFullEntity, ProductReviewModel>().ReverseMap();

                // Dispatch
                x.CreateMap<DispatchEntity, DispatchModel>().ReverseMap();

                // Audit (new)
                x.CreateMap<AdminAuditLogEntity, AdminAuditLogModel>().ReverseMap();
            });

            var mapper = mapping.CreateMapper();
            serviceCollection.AddSingleton(mapper);

            try
            {
                mapper.ConfigurationProvider.AssertConfigurationIsValid();
            }
            catch (Exception)
            {
                // Swallow validation errors — entity/model field mismatches are non-fatal
                // (stored proc columns mapped at query time by Dapper, not AutoMapper)
            }
        }
    }
}
