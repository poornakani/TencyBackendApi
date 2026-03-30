namespace TenzyBackend.Entity.ProcurementEntity
{
    public class ProcurementItemEntity
    {
        public int Id { get; set; }
        public int ProcurementOrderId { get; set; }
        public int? ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal UnitPriceGbp { get; set; }
    }
}
