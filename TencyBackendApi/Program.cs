using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Scrutor;
using SharedResources.API;
using System.Text;
using TencyBackendApi.Middleware;
using TenzyBackend.Core.Extentions;
using TenzyBackend.Core.Mapping;
using TenzyBackend.Core.Services.ProductsService.BrandService;
using TenzyBackend.Core.Services.TokenService;
using TenzyBackend.Data.Products.Brand;
using TenzyBackend.Data.UserLogin;
using TenzyBackend.DBContext;

var builder = WebApplication.CreateBuilder(args);

// ──────────────────────────────────────────────────────────────
// Core services
// ──────────────────────────────────────────────────────────────
builder.Services.AddMapping();
builder.Services.RegisterClassess();
builder.Services.AddControllers();
builder.Services.AddMemoryCache();

// ──────────────────────────────────────────────────────────────
// DI — explicit registrations + Scrutor assembly scan
// ──────────────────────────────────────────────────────────────
builder.Services.AddScoped<ITokenservice, Tokenservice>();
builder.Services.AddScoped<ILoginWriter, LoginWriter>();
builder.Services.AddScoped<DapperMethods>();
builder.Services.AddScoped<IObjectMapper, ObjectMapper>();

builder.Services.Scan(scan => scan
    .FromAssemblies(
        typeof(Program).Assembly,
        typeof(BrandService).Assembly,
        typeof(LoginWriter).Assembly
    )
    .AddClasses(classes => classes.Where(type =>
        type.Name.EndsWith("Service") ||
        type.Name.EndsWith("Reader")  ||
        type.Name.EndsWith("Writer")))
    .AsImplementedInterfaces()
    .WithScopedLifetime()
);

// ──────────────────────────────────────────────────────────────
// Swagger / OpenAPI with JWT support
// ──────────────────────────────────────────────────────────────
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Tenzy API", Version = "v1" });

    c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name         = "Authorization",
        Type         = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme       = "bearer",
        BearerFormat = "JWT",
        In           = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Description  = "Enter: Bearer {your token}"
    });
    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id   = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// ──────────────────────────────────────────────────────────────
// CORS — dev + GitHub Pages production
// ──────────────────────────────────────────────────────────────
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
        policy
            .WithOrigins(
                "http://localhost:5173",
                "http://localhost:3000",
                "https://poornakani.github.io"   // GitHub Pages production
            )
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials());
});

// ──────────────────────────────────────────────────────────────
// JWT Authentication
// ──────────────────────────────────────────────────────────────
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        var key = builder.Configuration["Jwt:Key"]
                  ?? throw new InvalidOperationException(
                      "Jwt:Key is missing. " +
                      "Run: dotnet user-secrets set \"Jwt:Key\" \"<min-32-char-key>\"");

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer           = true,
            ValidateAudience         = true,
            ValidateLifetime         = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer              = builder.Configuration["Jwt:Issuer"],
            ValidAudience            = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey         = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
            ClockSkew                = TimeSpan.Zero
        };
    });

builder.Services.AddAuthorization();

// ──────────────────────────────────────────────────────────────
// Build pipeline
// ──────────────────────────────────────────────────────────────
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Tenzy API v1"));
}

// Global error handler
app.UseMiddleware<GlobalExceptionMiddleware>();

// Rate limit auth endpoints (5 attempts / IP / minute) — before auth
app.UseMiddleware<AuthRateLimitMiddleware>();

app.UseCors("AllowFrontend");
app.UseHttpsRedirection();

// Ensure wwwroot/images exists so UseStaticFiles() works on first deploy
var imagesPath = Path.Combine(app.Environment.WebRootPath
                              ?? Path.Combine(app.Environment.ContentRootPath, "wwwroot"), "images");
Directory.CreateDirectory(imagesPath);
app.UseStaticFiles();   // serves wwwroot/ — product & brand images live at /images/*

app.UseAuthentication();
app.UseAuthorization();

// Admin audit log — after auth so ClaimsPrincipal is populated
app.UseMiddleware<AdminAuditMiddleware>();

app.MapControllers();
app.Run();
