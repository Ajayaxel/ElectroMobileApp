import 'package:equatable/equatable.dart';
import '../../data/models/address_model.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class FetchAddresses extends AddressEvent {}

class AddAddress extends AddressEvent {
  final AddressModel address;
  const AddAddress(this.address);

  @override
  List<Object?> get props => [address];
}

class EditAddress extends AddressEvent {
  final int id;
  final Map<String, dynamic> updates;
  const EditAddress(this.id, this.updates);

  @override
  List<Object?> get props => [id, updates];
}

class DeleteAddress extends AddressEvent {
  final int id;
  const DeleteAddress(this.id);

  @override
  List<Object?> get props => [id];
}
