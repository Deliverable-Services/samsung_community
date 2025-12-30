import '../models/content_model.dart';
import '../models/event_model.dart';
import '../models/store_product_model.dart';
import '../models/weekly_riddle_model.dart';

enum HomeItemType { event, weeklyRiddle, vod, podcast, storeProduct }

class HomeItem {
  final HomeItemType type;
  final DateTime createdAt;
  final String id;

  // Item data - only one will be non-null based on type
  final EventModel? event;
  final WeeklyRiddleModel? riddle;
  final ContentModel? vod;
  final ContentModel? podcast;
  final StoreProductModel? storeProduct;

  HomeItem({
    required this.type,
    required this.createdAt,
    required this.id,
    this.event,
    this.riddle,
    this.vod,
    this.podcast,
    this.storeProduct,
  }) : assert(
         (type == HomeItemType.event && event != null) ||
             (type == HomeItemType.weeklyRiddle && riddle != null) ||
             (type == HomeItemType.vod && vod != null) ||
             (type == HomeItemType.podcast && podcast != null) ||
             (type == HomeItemType.storeProduct && storeProduct != null),
       );

  factory HomeItem.fromEvent(EventModel event) {
    return HomeItem(
      type: HomeItemType.event,
      createdAt: event.createdAt,
      id: event.id,
      event: event,
    );
  }

  factory HomeItem.fromRiddle(WeeklyRiddleModel riddle) {
    return HomeItem(
      type: HomeItemType.weeklyRiddle,
      createdAt: riddle.createdAt,
      id: riddle.id,
      riddle: riddle,
    );
  }

  factory HomeItem.fromVod(ContentModel vod) {
    return HomeItem(
      type: HomeItemType.vod,
      createdAt: vod.createdAt,
      id: vod.id,
      vod: vod,
    );
  }

  factory HomeItem.fromPodcast(ContentModel podcast) {
    return HomeItem(
      type: HomeItemType.podcast,
      createdAt: podcast.createdAt,
      id: podcast.id,
      podcast: podcast,
    );
  }

  factory HomeItem.fromStoreProduct(StoreProductModel product) {
    return HomeItem(
      type: HomeItemType.storeProduct,
      createdAt: product.createdAt,
      id: product.id,
      storeProduct: product,
    );
  }
}
