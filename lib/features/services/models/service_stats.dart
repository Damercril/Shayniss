class ServiceStats {
  final int totalBookings;
  final double revenue;
  final double bookingRate;
  final int popularityRank;

  ServiceStats({
    required this.totalBookings,
    required this.revenue,
    required this.bookingRate,
    required this.popularityRank,
  });

  factory ServiceStats.fromJson(Map<String, dynamic> json) {
    return ServiceStats(
      totalBookings: json['totalBookings'] ?? 0,
      revenue: (json['revenue'] ?? 0.0).toDouble(),
      bookingRate: (json['bookingRate'] ?? 0.0).toDouble(),
      popularityRank: json['popularityRank'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBookings': totalBookings,
      'revenue': revenue,
      'bookingRate': bookingRate,
      'popularityRank': popularityRank,
    };
  }
}
