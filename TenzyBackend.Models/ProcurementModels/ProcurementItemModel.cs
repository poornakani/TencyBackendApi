namespace TenzyBackend.Models.ProcurementModels
{
    public class ProcurementItemModel
    {
        public int Id { get; set; }
        public int ProcurementOrderId { get; set; }
        public int? ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal UnitPriceGbp { get; set; }
    }
}
