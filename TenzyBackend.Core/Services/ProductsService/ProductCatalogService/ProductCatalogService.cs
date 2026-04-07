using SharedResources.Exceptions;
using System.Collections.Generic;
using System.Threading.Tasks;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Data.Products.Brand;
using TenzyBackend.Data.Products.Category;
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
        private readonly IBrandReader _brandReader;
        private readonly ICategoryReader _categoryReader;

        public ProductCatalogService(
            IProductCatalogReader reader,
            IProductCatalogWriter writer,
            IObjectMapper mapper,
            IBrandReader brandReader,
            ICategoryReader categoryReader)
        {
            _reader = reader;
            _writer = writer;
            _mapper = mapper;
            _brandReader = brandReader;
            _categoryReader = categoryReader;
        }

        public async Task<List<ProductCatalogModel>> GetAllProductsAsync()
        {
            var entities = await _reader.GetAllAsync();
            return _mapper.Map<List<ProductCatalogEntity>, List<ProductCatalogModel>>(entities);
        }

        public async Task<List<ProductCatalogModel>> GetAllProductsAdminAsync()
        {
            var entities = await _reader.GetAllAdminAsync();
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
            if (request.OriginalPrice < 0)
                throw new ValidationException("Original price cannot be negative.");
            if (request.StockQuantity < 0)
                throw new ValidationException("Stock quantity cannot be negative.");
            if (await _brandReader.GetByIdAsync(request.BrandId) == null)
                throw new ValidationException("Selected brand was not found.");
            if (await _categoryReader.GetByIdAsync(request.CategoryId) == null)
                throw new ValidationException("Selected category was not found.");

            return await _writer.CreateAsync(request);
        }

        public async Task<bool> UpdateProductAsync(UpdateProductRequest request)
        {
            if (request.ProductId <= 0)
                throw new ValidationException("Invalid product id.");
            if (string.IsNullOrWhiteSpace(request.Name))
                throw new ValidationException("Product name is required.");
            if (request.BrandId <= 0)
                throw new ValidationException("Brand is required.");
            if (request.CategoryId <= 0)
                throw new ValidationException("Category is required.");
            if (request.SellingPrice.HasValue && request.SellingPrice.Value < 0)
                throw new ValidationException("Selling price cannot be negative.");
            if (request.OriginalPrice.HasValue && request.OriginalPrice.Value < 0)
                throw new ValidationException("Original price cannot be negative.");
            if (request.StockQuantity.HasValue && request.StockQuantity.Value < 0)
                throw new ValidationException("Stock quantity cannot be negative.");
            if (await _brandReader.GetByIdAsync(request.BrandId) == null)
                throw new ValidationException("Selected brand was not found.");
            if (await _categoryReader.GetByIdAsync(request.CategoryId) == null)
                throw new ValidationException("Selected category was not found.");

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

        public async Task<List<int>> GetProductConcernIdsAsync(int productId)
        {
            if (productId <= 0)
                throw new ValidationException("Invalid product id.");
            return await _reader.GetProductConcernIdsAsync(productId);
        }

        public async Task<List<ProductPaymentOptionModel>> GetProductPaymentOptionsAsync(int productId)
        {
            if (productId <= 0)
                throw new ValidationException("Invalid product id.");
            return await _reader.GetProductPaymentOptionsAsync(productId);
        }
    }
}
