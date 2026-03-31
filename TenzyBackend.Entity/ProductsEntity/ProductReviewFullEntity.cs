using System;

namespace TenzyBackend.Entity.ProductsEntity
{
    public class ProductReviewFullEntity
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

    public class ReviewAggregateEntity
    {
        public int TotalReviews { get; set; }
        public double AvgRating { get; set; }
    }
}
