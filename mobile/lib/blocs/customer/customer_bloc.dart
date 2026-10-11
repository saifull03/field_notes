import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/sync_service.dart';
import '../../models/customer_model.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final StorageService storageService;
  final SyncService syncService;
  final _uuid = const Uuid();

  CustomerBloc({
    required this.storageService,
    required this.syncService,
  }) : super(CustomerInitial()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<AddCustomerEvent>(_onAddCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
  }

  void _onLoadCustomers(LoadCustomersEvent event, Emitter<CustomerState> emit) {
    emit(CustomerLoading());
    try {
      final customers = storageService.getAllCustomers();
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onAddCustomer(AddCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      final newCustomer = CustomerModel(
        id: _uuid.v4(),
        name: event.name.trim(),
        contactInformation: event.contactInformation?.trim(),
        isSynced: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await storageService.saveCustomer(newCustomer);
      emit(const CustomerOperationSuccess('Customer created successfully'));

      // Reload list
      final customers = storageService.getAllCustomers();
      emit(CustomerLoaded(customers));

      // Trigger background sync
      syncService.synchronize();
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(UpdateCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      final updated = event.customer.copyWith(
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      await storageService.saveCustomer(updated);
      emit(const CustomerOperationSuccess('Customer updated successfully'));

      // Reload list
      final customers = storageService.getAllCustomers();
      emit(CustomerLoaded(customers));

      // Trigger background sync
      syncService.synchronize();
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(DeleteCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      await storageService.deleteCustomer(event.customerId);
      emit(const CustomerOperationSuccess('Customer deleted successfully'));

      // Reload list
      final customers = storageService.getAllCustomers();
      emit(CustomerLoaded(customers));

      // Trigger background sync
      syncService.synchronize();
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}
