using System;
using System.Collections.Generic;

namespace TenzyBackend.Models.ProductsModels
{
    public class ProductReviewModel
    {
        public int Id { get; set; }
        public int ProductId { get; set; }
        public string? ProductName { get; set; }
        public Guid UserId { get; set; }
        public string DisplayName { get; set; } = string.Empty;
        public byte Rate { get; set; }
        public string? Comment { get; set; }
        public bool IsVerifiedPurchase { get; set; }
        public bool IsApproved { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class ProductReviewListModel
    {
        public List<ProductReviewModel> Reviews { get; set; } = new();
        public int TotalReviews { get; set; }
        public double AvgRating { get; set; }
    }

    public class CreateReviewRequest
    {
        public int ProductId { get; set; }
        public byte Rate { get; set; }
        public string? Comment { get; set; }
    }

    public class ModerateReviewRequest
    {
        public bool IsApproved { get; set; }
    }
}
