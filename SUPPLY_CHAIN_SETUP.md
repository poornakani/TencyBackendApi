# Supply Chain Setup

## What was added

- New SQL Server migration:
  - `Database/migrations/011_supply_chain_management.sql`
- New admin API:
  - `TencyBackendApi/Controllers/SupplyChainController.cs`
- New Dapper reader/writer and service:
  - `TenzyBackend.Data/SupplyChain/*`
  - `TenzyBackend.Core/Services/SupplyChainService/*`
- New shared models:
  - `TenzyBackend.Models/SupplyChainModels/SupplyChainModels.cs`

## Covered modules

1. Procurement
2. Discount capture and allocation
3. UK dispatch
4. Shipment charges
5. Arrival verification
6. Pricing approval
7. Procurement, dispatch, and monthly summary reporting

## Database notes

The migration intentionally drops the older simplified procurement/dispatch tables and procedures:

- `ProcurementOrders`
- `ProcurementItems`
- `Dispatch`
- related old procurement/dispatch stored procedures

It replaces them with:

- `SupplyProcurements`
- `SupplyProcurementItems`
- `SupplyProcurementDiscounts`
- `SupplyProcurementDiscountAllocations`
- `SupplyShipments`
- `SupplyShipmentItems`
- `SupplyShipmentCharges`
- `SupplyArrivalVerifications`
- `SupplyArrivalItems`
- `SupplyPricing`

## Main API routes

- `GET /api/admin/supply-chain/dashboard`
- `GET/POST /api/admin/supply-chain/procurements`
- `GET /api/admin/supply-chain/procurements/{id}`
- `GET/POST /api/admin/supply-chain/dispatches`
- `GET /api/admin/supply-chain/dispatches/{id}`
- `POST /api/admin/supply-chain/dispatches/{id}/charges`
- `GET/POST /api/admin/supply-chain/arrivals`
- `GET /api/admin/supply-chain/arrivals/{id}`
- `GET /api/admin/supply-chain/pricing/eligible`
- `GET/POST /api/admin/supply-chain/pricing`
- `GET /api/admin/supply-chain/reports/procurement`
- `GET /api/admin/supply-chain/reports/dispatch`
- `GET /api/admin/supply-chain/reports/monthly-dispatch-summary`

## Testing

Frontend-side automated utility tests:

- `cd /Users/poornakanishka/Tenzy_shop`
- `npm run test:supply-chain`

End-to-end smoke script using a real admin login:

- `npm run test:supply-chain:api`

This script needs:

- `TENZY_API_BASE_URL`
- `TENZY_ADMIN_EMAIL`
- `TENZY_ADMIN_PASSWORD`

## Local verification limits in this environment

- Frontend build completed successfully.
- Backend compile could not be executed here because the local machine is missing the required .NET runtime/tooling for this solution target.
