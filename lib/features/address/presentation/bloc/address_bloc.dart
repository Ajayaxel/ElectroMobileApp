import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/address_repository.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository addressRepository;

  AddressBloc(this.addressRepository) : super(AddressInitial()) {
    on<FetchAddresses>(_onFetchAddresses);
    on<AddAddress>(_onAddAddress);
    on<EditAddress>(_onEditAddress);
    on<DeleteAddress>(_onDeleteAddress);
  }

  Future<void> _onFetchAddresses(
    FetchAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final addresses = await addressRepository.fetchAddresses();
      emit(AddressLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onAddAddress(
    AddAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      await addressRepository.createAddress(event.address);
      final addresses = await addressRepository.fetchAddresses();
      emit(const AddressActionSuccess('Address added successfully'));
      emit(AddressLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onEditAddress(
    EditAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      await addressRepository.updateAddress(event.id, event.updates);
      final addresses = await addressRepository.fetchAddresses();
      emit(const AddressActionSuccess('Address updated successfully'));
      emit(AddressLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onDeleteAddress(
    DeleteAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      await addressRepository.deleteAddress(event.id);
      final addresses = await addressRepository.fetchAddresses();
      emit(const AddressActionSuccess('Address deleted successfully'));
      emit(AddressLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }
}
