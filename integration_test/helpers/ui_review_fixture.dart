import 'package:model/model.dart';

/// UIレビューで日時・場所・メモの表示を確認できる固定Pinを返す。
List<Pin> buildUiReviewPins() => [
  Pin(
    id: 1,
    latitude: const Latitude(35.681236),
    longitude: const Longitude(139.767125),
    createdAt: MyDatetime(DateTime(2026, 8, 30, 9, 15)),
    memo: Memo('朝の集合場所・丸の内北口'),
  ),
  Pin(
    id: 2,
    latitude: const Latitude(35.658581),
    longitude: const Longitude(139.745433),
    createdAt: MyDatetime(DateTime(2026, 8, 30, 12, 40)),
    memo: Memo('展望台を見学'),
    reviewStatus: PinReviewStatus.reviewed,
  ),
  Pin(
    id: 3,
    latitude: const Latitude(35.710063),
    longitude: const Longitude(139.8107),
    createdAt: MyDatetime(DateTime(2026, 8, 30, 16, 5)),
    memo: Memo('夕方の休憩スポット'),
    reviewStatus: PinReviewStatus.reviewed,
  ),
  Pin(
    id: 4,
    latitude: const Latitude(35.676398),
    longitude: const Longitude(139.699326),
    createdAt: MyDatetime(DateTime(2026, 8, 30, 19, 30)),
  ),
];
