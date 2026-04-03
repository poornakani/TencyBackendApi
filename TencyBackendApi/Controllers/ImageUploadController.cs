using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace TencyBackendApi.Controllers
{
    [Route("api/upload")]
    [ApiController]
    [Authorize(Roles = "3")]
    public class ImageUploadController : ControllerBase
    {
        private readonly IWebHostEnvironment _env;
        private readonly IConfiguration _config;

        public ImageUploadController(IWebHostEnvironment env, IConfiguration config)
        {
            _env = env;
            _config = config;
        }

        /// <summary>
        /// POST /api/upload/image
        /// Saves the uploaded image to the configured folder and returns its public URL.
        /// Configure "ImageUpload:FolderPath" in appsettings to override the default path.
        /// </summary>
        [HttpPost("image")]
        public async Task<IActionResult> UploadImage(IFormFile file)
        {
            try
            {
                if (file == null || file.Length == 0)
                    return BadRequest(new { result = false, message = "No file provided." });

                var allowedTypes = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
                {
                    "image/jpeg", "image/jpg", "image/png", "image/webp", "image/gif"
                };

                if (!allowedTypes.Contains(file.ContentType))
                    return BadRequest(new { result = false, message = "Only JPEG, PNG, WebP, and GIF images are allowed." });

                const long maxSize = 5 * 1024 * 1024; // 5 MB
                if (file.Length > maxSize)
                    return BadRequest(new { result = false, message = "File size must be under 5 MB." });

                // Resolve save folder:
                // 1. appsettings "ImageUpload:FolderPath"  (absolute path on server — set this in production)
                // 2. wwwroot/images  (default for local dev)
                var configuredPath = _config["ImageUpload:FolderPath"];
                string imagesDir;

                if (!string.IsNullOrWhiteSpace(configuredPath))
                {
                    imagesDir = configuredPath;
                }
                else
                {
                    var webRoot = _env.WebRootPath ?? Path.Combine(_env.ContentRootPath, "wwwroot");
                    imagesDir = Path.Combine(webRoot, "images");
                }

                Directory.CreateDirectory(imagesDir);

                var ext      = Path.GetExtension(file.FileName).ToLowerInvariant();
                var fileName = $"{Guid.NewGuid()}{ext}";
                var filePath = Path.Combine(imagesDir, fileName);

                await using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                // Resolve public URL:
                // Use "ImageUpload:BaseUrl" from appsettings if set; otherwise derive from request host.
                var baseUrl  = _config["ImageUpload:BaseUrl"]?.TrimEnd('/')
                               ?? $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}";
                var url = $"{baseUrl}/images/{fileName}";

                return Ok(new { result = true, url });
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(500, new { result = false, message = $"Permission denied writing to images folder: {ex.Message}" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { result = false, message = $"Upload failed: {ex.Message}" });
            }
        }
    }
}
