import 'package:equatable/equatable.dart';
import '../../models/customer_model.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => [];
}

class LoadCustomersEvent extends CustomerEvent {}

class AddCustomerEvent extends CustomerEvent {
  final String name;
  final String? contactInformation;

  const AddCustomerEvent({required this.name, this.contactInformation});

  @override
  List<Object?> get props => [name, contactInformation];
}

class UpdateCustomerEvent extends CustomerEvent {
  final CustomerModel customer;

  const UpdateCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class DeleteCustomerEvent extends CustomerEvent {
  final String customerId;

  const DeleteCustomerEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}
