import 'package:odoo_scanner/data/local/database.dart';
import 'package:odoo_scanner/data/odoo/crm_models.dart';
import 'package:odoo_scanner/data/odoo/models.dart';
import 'package:odoo_scanner/data/odoo/sales_models.dart';

/// Shared working-set fixtures for UX and screenshot tests.
Future<void> seedCrm(AppDatabase db) => db.replaceCrmWorkingSet(
  remoteLeads: [
    const RemoteLead(
      id: 1,
      name: 'Big deal',
      partnerName: 'Acme',
      stageId: 2,
      stageName: 'New',
      expectedRevenue: 1200,
    ),
    const RemoteLead(
      id: 2,
      name: 'Bigger deal',
      stageId: 3,
      stageName: 'Qualified',
    ),
  ],
  remoteStages: [
    const RemoteCrmStage(id: 2, name: 'New', sequence: 0),
    const RemoteCrmStage(id: 3, name: 'Qualified', sequence: 1),
  ],
);

Future<void> seedSales(AppDatabase db) => db.replaceSalesWorkingSet(
  remoteOrders: [
    const RemoteSaleOrder(
      id: 9,
      name: 'S00009',
      state: 'sent',
      partnerName: 'Acme',
      amountTotal: 100,
    ),
  ],
  remoteLines: [
    const RemoteSaleOrderLine(
      id: 90,
      orderId: 9,
      description: 'Widget',
      quantity: 2,
      priceSubtotal: 50,
    ),
  ],
);

Future<void> seedWarehouse(AppDatabase db) => db.replaceWorkingSet(
  remotePickings: [
    const RemotePicking(
      id: 1,
      name: 'WH/IN/00001',
      state: 'assigned',
      pickingTypeCode: 'incoming',
      partnerName: 'Acme Supply',
    ),
  ],
  remoteMoveLines: [
    const RemoteMoveLine(
      id: 10,
      pickingId: 1,
      productId: 100,
      productName: 'Widget',
      quantity: 0,
      picked: false,
    ),
  ],
  remoteProducts: [
    const RemoteProduct(id: 100, name: 'Widget', barcode: '111'),
  ],
);
