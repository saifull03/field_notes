import 'package:equatable/equatable.dart';
import '../../models/site_model.dart';

abstract class SiteEvent extends Equatable {
  const SiteEvent();
  @override
  List<Object?> get props => [];
}

class LoadSitesEvent extends SiteEvent {
  final String? customerId;

  const LoadSitesEvent({this.customerId});

  @override
  List<Object?> get props => [customerId];
}

class AddSiteEvent extends SiteEvent {
  final String customerId;
  final String name;
  final String? address;

  const AddSiteEvent({
    required this.customerId,
    required this.name,
    this.address,
  });

  @override
  List<Object?> get props => [customerId, name, address];
}

class UpdateSiteEvent extends SiteEvent {
  final SiteModel site;

  const UpdateSiteEvent(this.site);

  @override
  List<Object?> get props => [site];
}

class DeleteSiteEvent extends SiteEvent {
  final String siteId;

  const DeleteSiteEvent(this.siteId);

  @override
  List<Object?> get props => [siteId];
}

