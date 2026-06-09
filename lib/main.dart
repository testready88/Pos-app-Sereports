import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/bank_details/bank_details_bloc.dart';
import 'package:sereports/bloc/bank_name/bank_name_bloc.dart';
import 'package:sereports/bloc/bank_transaction/bank_transaction_bloc.dart';
import 'package:sereports/bloc/category/category_bloc.dart';
import 'package:sereports/bloc/customer_debitors/customer_debitor_bloc.dart';
import 'package:sereports/bloc/customer_details/customer%20_details_bloc.dart';
import 'package:sereports/bloc/customer_receivable/customer_receivable_bloc.dart';
import 'package:sereports/bloc/dashboard/dashboard_bloc.dart';
import 'package:sereports/bloc/incom_expences/incom_expences_bloc.dart';
import 'package:sereports/bloc/invoice_create/invoice_create_bloc.dart';
import 'package:sereports/bloc/product/product_bloc.dart';
import 'package:sereports/bloc/purchase_details/purchase_details_bloc.dart';
import 'package:sereports/bloc/purchase_summery/purchase_summery_bloc.dart';
import 'package:sereports/bloc/sales_details/sales_details_bloc.dart';
import 'package:sereports/bloc/sales_summery/sales_summery_bloc.dart';
import 'package:sereports/bloc/subcategory/sub_category_bloc.dart';
import 'package:sereports/bloc/supplier%20details/supplier_details_bloc.dart';
import 'package:sereports/bloc/supplier/supplier_bloc.dart';
import 'package:sereports/bloc/supplier_creditor/creditor_bloc.dart';
import 'package:sereports/bloc/supplier_payable/supplier_payable_bloc.dart';
import 'package:sereports/repository/auth_repo.dart';
import 'package:sereports/repository/bank_repo.dart';
import 'package:sereports/repository/category_repo.dart';
import 'package:sereports/repository/customer_repo.dart';
import 'package:sereports/repository/dashboard_repo.dart';
import 'package:sereports/repository/incom_expences_repo.dart';
import 'package:sereports/repository/product_repo.dart';
import 'package:sereports/repository/purchase_repo.dart';
import 'package:sereports/repository/sales_repo.dart';
import 'package:sereports/repository/sub_category_repo.dart';
import 'package:sereports/repository/supplier_repo.dart';
import 'package:sereports/screen/splash_screen/splash_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sereports/repository/invoice_create_repo.dart';
import 'package:sereports/db/local_invoice_db.dart';
import 'package:sereports/utils/connectivity_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database
  final localDb = LocalInvoiceDatabase();
  await localDb.initializeDatabase();

  // Initialize connectivity
  final connectivity = Connectivity();

  // Initialize repository
  final invoiceRepository = InvoiceRepository(
    connectivity: connectivity,
    localDb: localDb,
  );

  // Initialize connectivity listener for auto-sync
  final connectivityListener = ConnectivityListener(
    connectivity: connectivity,
    invoiceRepository: invoiceRepository,
  );
  connectivityListener.startListening();

  runApp(MyApp(
    invoiceRepository: invoiceRepository,
    localDb: localDb,
    connectivity: connectivity,
    connectivityListener: connectivityListener,
  ));
}

class MyApp extends StatelessWidget {
  final InvoiceRepository invoiceRepository;
  final LocalInvoiceDatabase localDb;
  final Connectivity connectivity;

  const MyApp({
    super.key,
    required this.invoiceRepository,
    required this.localDb,
    required this.connectivity,
    required ConnectivityListener connectivityListener,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SupplierBloc>(
          create: (context) => SupplierBloc(
            supplierRepo: SupplierRepo(),
          ),
        ),
        BlocProvider<SupplierDetailsBloc>(
          create: (context) => SupplierDetailsBloc(
            supplierRepo: SupplierRepo(),
          ),
        ),
        BlocProvider<CreditorBloc>(
          create: (context) => CreditorBloc(
            supplierRepo: SupplierRepo(),
          ),
        ),
        BlocProvider<SupplierPayableBloc>(
          create: (context) => SupplierPayableBloc(
            supplierRepo: SupplierRepo(),
          ),
        ),
        BlocProvider<CustomerDetailsBloc>(
          create: (context) =>
              CustomerDetailsBloc(customerRepo: CustomerRepo()),
        ),
        BlocProvider<DebitorsBloc>(
          create: (context) => DebitorsBloc(customerRepo: CustomerRepo()),
        ),
        BlocProvider<ReceivableBloc>(
          create: (context) => ReceivableBloc(customerRepo: CustomerRepo()),
        ),
        BlocProvider<BankBloc>(
          create: (context) => BankBloc(
            bankRepo: BankRepository(),
          ),
        ),
        BlocProvider<BankDetailsBloc>(
          create: (context) => BankDetailsBloc(
            repository: BankRepository(),
          ),
        ),
        BlocProvider<BankTransactionBloc>(
          create: (context) => BankTransactionBloc(
            bankRepo: BankRepository(),
          ),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(
            repository: DashboardRepository(),
          ),
        ),
        BlocProvider<SalesSummaryBloc>(
          create: (context) => SalesSummaryBloc(
            salesRepo: SalesRepo(),
          ),
        ),
        BlocProvider<SalesDetailsBloc>(
          create: (context) => SalesDetailsBloc(salesRepo: SalesRepo()),
        ),
        BlocProvider<PurchaseHistoryBloc>(
          create: (context) => PurchaseHistoryBloc(repo: PurchaseRepo()),
        ),
        BlocProvider<PurchaseSummaryBloc>(
          create: (context) => PurchaseSummaryBloc(repo: PurchaseRepo()),
        ),
        BlocProvider<IncomeExpensesBloc>(
          create: (context) => IncomeExpensesBloc(repo: IncomeExpencesRepo()),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(
            categoryRepo: CategoryRepo(),
          ),
        ),
        BlocProvider<SubCategoryBloc>(
          create: (context) => SubCategoryBloc(
            subCategoryRepo: SubCategoryRepo(),
          ),
        ),
        BlocProvider<ProductBloc>(
          create: (context) => ProductBloc(productRepo: ProductRepo()),
        ),
        BlocProvider<InvoiceCreationBloc>(
          create: (context) => InvoiceCreationBloc(
            repository: invoiceRepository,
            connectivity: connectivity,
          ),
        ),
        RepositoryProvider<LocalInvoiceDatabase>(
          create: (_) => localDb,
        ),
        RepositoryProvider<Connectivity>(
          create: (_) => connectivity,
        ),
        RepositoryProvider<InvoiceRepository>(
          create: (_) => invoiceRepository,
        ),
      ],
      child: MaterialApp(
        navigatorKey: AuthRepo.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Se POS',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
