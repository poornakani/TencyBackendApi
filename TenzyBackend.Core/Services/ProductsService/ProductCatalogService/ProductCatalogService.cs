using SharedResources.Exceptions;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Data.Products.ProductCatalog;
using TenzyBackend.Entity.ProductsEntity;
using TenzyBackend.Models.ProductsModels;

namespace TenzyBackend.Core.Services.ProductsService.ProductCatalogService
{
    public class ProductCatalogService : IProductCatalogService
    {
        private readonly IProductCatalogReader _reader;
        private readonly IProductCatalogWriter _writer;
        private readonly IObjectMapper _mapper;

        public ProductCatalogService(
            IProductCatalogReader reader,
            IProductCatalogWriter writer,
            IObjectMapper mapper)
        {
            _reader = reader;
            _writer = writer;
            _mapper = mapper;
        }

        public async Task<List<ProductCatalogModel>> GetAllProductsAsync()
        {
            var entities = await _reader.GetAllAsync();
            return _mapper.Map<List<ProductCatalogEntity>, List<ProductCatalogModel>>(entities);
        }

        public async Task<ProductCatalogModel> GetProductByIdAsync(int productId)
        {
            if (productId <= 0)
                throw new ValidationException("Invalid product id.");

            var entity = await _reader.GetByIdAsync(productId)
                ?? throw new NotFoundException("Product not found.");

            return _mapper.Map<ProductCatalogEntity, ProductCatalogModel>(entity);
        }

        public async Task<int> CreateProductAsync(CreateProductRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Name))
                throw new ValidationException("Product name is required.");
            if (request.BrandId <= 0)
                throw new ValidationException("Brand is required.");
            if (request.CategoryId <= 0)
                throw new ValidationException("Category is required.");
            if (request.SellingPrice < 0)
                throw new ValidationException("Selling price cannot be negative.");

            return await _writer.CreateAsync(request);
        }

        public async Task<bool> UpdateProductAsync(UpdateProductRequest request)
        {
            if (request.ProductId <= 0)
                throw new ValidationException("Invalid product id.");
            if (string.IsNullOrWhiteSpace(request.Name))
                throw new ValidationException("Product name is required.");

            var existing = await _reader.GetByIdAsync(request.ProductId)
                ?? throw new NotFoundException("Product not found.");

            return await _writer.UpdateAsync(request);
        }

        public async Task<bool> DeactivateProductAsync(int productId)
        {
            if (productId <= 0)
                throw new ValidationException("Invalid product id.");

            var existing = await _reader.GetByIdAsync(productId)
                ?? throw new NotFoundException("Product not found.");

            return await _writer.DeactivateAsync(productId);
        }
    }
}
