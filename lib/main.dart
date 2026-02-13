import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electro/core/network/api_client.dart';
import 'package:electro/data/repositories/brand_repository.dart';
import 'package:electro/logic/blocs/brand/brand_bloc.dart';
import 'package:electro/logic/blocs/brand/brand_event.dart';

import 'package:electro/data/repositories/vehicle_repository.dart';
import 'package:electro/logic/blocs/vehicle_model/vehicle_model_bloc.dart';
import 'package:electro/logic/blocs/vehicle_model/vehicle_model_event.dart';

import 'package:electro/data/repositories/issue_repository.dart';
import 'package:electro/logic/blocs/issue_category/issue_category_bloc.dart';
import 'package:electro/logic/blocs/issue_category/issue_category_event.dart';

import 'package:electro/data/repositories/chat_repository.dart';
import 'package:electro/logic/blocs/chat/chat_bloc.dart';
import 'package:electro/data/repositories/charging_type_repository.dart';
import 'package:electro/logic/blocs/charging_type/charging_type_bloc.dart';
import 'package:electro/logic/blocs/charging_type/charging_type_event.dart';
import 'package:electro/data/repositories/auth_repository.dart';
import 'package:electro/logic/blocs/auth/auth_bloc.dart';
import 'package:electro/logic/blocs/add_vehicle/add_vehicle_bloc.dart';
import 'package:electro/logic/blocs/vehicle_list/vehicle_list_bloc.dart';
import 'package:electro/logic/blocs/vehicle_list/vehicle_list_event.dart';
import 'package:electro/logic/blocs/ticket/ticket_bloc.dart';
import 'package:electro/logic/blocs/delete_vehicle/delete_vehicle_bloc.dart';
import 'package:electro/data/repositories/profile_repository.dart';
import 'package:electro/logic/blocs/profile/profile_bloc.dart';
import 'package:electro/logic/blocs/profile/profile_event.dart';
import 'package:electro/data/repositories/location_repository.dart';
import 'package:electro/logic/blocs/location/location_bloc.dart';
import 'package:electro/logic/blocs/location/location_event.dart';
import 'package:electro/screen/onbording/splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final brandRepository = BrandRepository(apiClient: apiClient);
  final vehicleRepository = VehicleRepository(apiClient: apiClient);
  final issueRepository = IssueRepository(apiClient: apiClient);
  final chatRepository = ChatRepository(apiClient: apiClient);
  final chargingTypeRepository = ChargingTypeRepository(apiClient: apiClient);
  final authRepository = AuthRepository(apiClient: apiClient);
  final profileRepository = ProfileRepository(apiClient: apiClient);
  final locationRepository = LocationRepository(apiClient: apiClient);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BrandRepository>.value(value: brandRepository),
        RepositoryProvider<VehicleRepository>.value(value: vehicleRepository),
        RepositoryProvider<IssueRepository>.value(value: issueRepository),
        RepositoryProvider<ChatRepository>.value(value: chatRepository),
        RepositoryProvider<ChargingTypeRepository>.value(
          value: chargingTypeRepository,
        ),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
        RepositoryProvider<LocationRepository>.value(value: locationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BrandBloc>(
            create: (context) =>
                BrandBloc(brandRepository: brandRepository)..add(FetchBrands()),
          ),
          BlocProvider<VehicleModelBloc>(
            create: (context) =>
                VehicleModelBloc(vehicleRepository: vehicleRepository)
                  ..add(FetchVehicleModels()),
          ),
          BlocProvider<IssueCategoryBloc>(
            create: (context) =>
                IssueCategoryBloc(issueRepository: issueRepository)
                  ..add(FetchIssueCategories()),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(chatRepository: chatRepository),
          ),
          BlocProvider<ChargingTypeBloc>(
            create: (context) =>
                ChargingTypeBloc(chargingTypeRepository: chargingTypeRepository)
                  ..add(FetchChargingTypes()),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: authRepository),
          ),
          BlocProvider<AddVehicleBloc>(
            create: (context) =>
                AddVehicleBloc(vehicleRepository: vehicleRepository),
          ),
          BlocProvider<VehicleListBloc>(
            create: (context) =>
                VehicleListBloc(vehicleRepository: vehicleRepository)
                  ..add(FetchVehicles()),
          ),
          BlocProvider<TicketBloc>(
            create: (context) => TicketBloc(issueRepository: issueRepository),
          ),
          BlocProvider<DeleteVehicleBloc>(
            create: (context) =>
                DeleteVehicleBloc(vehicleRepository: vehicleRepository),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) =>
                ProfileBloc(profileRepository: profileRepository)
                  ..add(FetchProfile()),
          ),
          BlocProvider<LocationBloc>(
            create: (context) =>
                LocationBloc(repository: locationRepository)
                  ..add(FetchLocations()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Lufga',
      ),
      home: const SplashScreen(),
    );
  }
}
