using Microsoft.AspNetCore.Authentication.JwtBearer;

using Microsoft.IdentityModel.Tokens;

using Microsoft.OpenApi;
using SharedResources.API;
using System.Text;
using Scrutor;
using TenzyBackend.Core.Extentions;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Core.Services.ProductsService.BrandService;
using TenzyBackend.Core.Services.ProductsService.CatagoryService;
using TenzyBackend.Core.Services.ProductsService.ConcernService;
using TenzyBackend.Core.Services.TokenService;
using TenzyBackend.Data.Products.Brand;
using TenzyBackend.Data.Products.Category;
using TenzyBackend.Data.Products.ConcernType;
using TenzyBackend.Data.UserLogin;
using TenzyBackend.DBContext;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddMapping();
builder.Services.RegisterClassess();
builder.Services.AddControllers();

builder.Services.AddScoped<ITokenservice, Tokenservice>();
builder.Services.AddScoped<ILoginWriter, LoginWriter>();

builder.Services.Scan(scan => scan
    .FromAssemblies(
        typeof(Program).Assembly,
        typeof(BrandService).Assembly,
        typeof(LoginWriter).Assembly
    )
    .AddClasses(classes => classes.Where(type =>
        type.Name.EndsWith("Service") ||
        type.Name.EndsWith("Reader") ||
        type.Name.EndsWith("Writer")))
        .AsImplementedInterfaces()
        .WithScopedLifetime()
);



builder.Services.AddScoped<DapperMethods>();   

// IObjectMapper should already be registered by AddMapping(), but if not:
builder.Services.AddScoped<IObjectMapper, ObjectMapper>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "My API",
        Version = "v1"
    });
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend",
        policy => policy.WithOrigins("http://localhost:5173", "http://localhost:3000")
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .AllowCredentials());
});

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        var key = builder.Configuration["Jwt:Key"]
                  ?? throw new InvalidOperationException("Jwt:Key is missing");

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key))
        };
    });

builder.Services.AddAuthorization();


var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API v1");
        // c.RoutePrefix = ""; // set Swagger at /
    });
}

app.UseMiddleware<GlobalExceptionMiddleware>();
app.UseCors("AllowFrontend");
app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();