class BusinessHours {
  final String day;
  final bool isOpen;
  final String? openTime;
  final String? closeTime;
  final bool hasLunchBreak;
  final String? lunchStart;
  final String? lunchEnd;

  BusinessHours({
    required this.day,
    required this.isOpen,
    this.openTime,
    this.closeTime,
    this.hasLunchBreak = false,
    this.lunchStart,
    this.lunchEnd,
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'isOpen': isOpen,
        'openTime': openTime,
        'closeTime': closeTime,
        'hasLunchBreak': hasLunchBreak,
        'lunchStart': lunchStart,
        'lunchEnd': lunchEnd,
      };

  factory BusinessHours.fromJson(Map<String, dynamic> json) => BusinessHours(
        day: json['day'],
        isOpen: json['isOpen'],
        openTime: json['openTime'],
        closeTime: json['closeTime'],
        hasLunchBreak: json['hasLunchBreak'],
        lunchStart: json['lunchStart'],
        lunchEnd: json['lunchEnd'],
      );
}

class BusinessSettings {
  final String businessName;
  final String address;
  final String phone;
  final String email;
  final String? website;
  final String? instagram;
  final String? facebook;
  final List<BusinessHours> businessHours;
  final int defaultAppointmentDuration;
  final bool allowOnlineBooking;
  final bool requireDeposit;
  final double? depositAmount;
  final String currency;
  final String language;
  final bool enableNotifications;
  final bool enableSMS;
  final bool enableEmails;

  BusinessSettings({
    required this.businessName,
    required this.address,
    required this.phone,
    required this.email,
    this.website,
    this.instagram,
    this.facebook,
    required this.businessHours,
    this.defaultAppointmentDuration = 60,
    this.allowOnlineBooking = true,
    this.requireDeposit = false,
    this.depositAmount,
    this.currency = 'EUR',
    this.language = 'fr',
    this.enableNotifications = true,
    this.enableSMS = false,
    this.enableEmails = true,
  });

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'address': address,
        'phone': phone,
        'email': email,
        'website': website,
        'instagram': instagram,
        'facebook': facebook,
        'businessHours': businessHours.map((h) => h.toJson()).toList(),
        'defaultAppointmentDuration': defaultAppointmentDuration,
        'allowOnlineBooking': allowOnlineBooking,
        'requireDeposit': requireDeposit,
        'depositAmount': depositAmount,
        'currency': currency,
        'language': language,
        'enableNotifications': enableNotifications,
        'enableSMS': enableSMS,
        'enableEmails': enableEmails,
      };

  factory BusinessSettings.fromJson(Map<String, dynamic> json) => BusinessSettings(
        businessName: json['businessName'],
        address: json['address'],
        phone: json['phone'],
        email: json['email'],
        website: json['website'],
        instagram: json['instagram'],
        facebook: json['facebook'],
        businessHours: (json['businessHours'] as List)
            .map((h) => BusinessHours.fromJson(h))
            .toList(),
        defaultAppointmentDuration: json['defaultAppointmentDuration'],
        allowOnlineBooking: json['allowOnlineBooking'],
        requireDeposit: json['requireDeposit'],
        depositAmount: json['depositAmount'],
        currency: json['currency'],
        language: json['language'],
        enableNotifications: json['enableNotifications'],
        enableSMS: json['enableSMS'],
        enableEmails: json['enableEmails'],
      );

  // Données de test
  static BusinessSettings get sample => BusinessSettings(
        businessName: 'Mon Salon de Beauté',
        address: '123 Rue de la Beauté, 75001 Paris',
        phone: '+33 1 23 45 67 89',
        email: 'contact@monsalon.com',
        website: 'www.monsalon.com',
        instagram: '@monsalonbeaute',
        facebook: 'monsalonbeaute',
        businessHours: [
          BusinessHours(
            day: 'Lundi',
            isOpen: true,
            openTime: '09:00',
            closeTime: '19:00',
            hasLunchBreak: true,
            lunchStart: '12:00',
            lunchEnd: '13:00',
          ),
          BusinessHours(
            day: 'Mardi',
            isOpen: true,
            openTime: '09:00',
            closeTime: '19:00',
            hasLunchBreak: true,
            lunchStart: '12:00',
            lunchEnd: '13:00',
          ),
          BusinessHours(
            day: 'Mercredi',
            isOpen: true,
            openTime: '09:00',
            closeTime: '19:00',
            hasLunchBreak: true,
            lunchStart: '12:00',
            lunchEnd: '13:00',
          ),
          BusinessHours(
            day: 'Jeudi',
            isOpen: true,
            openTime: '09:00',
            closeTime: '19:00',
            hasLunchBreak: true,
            lunchStart: '12:00',
            lunchEnd: '13:00',
          ),
          BusinessHours(
            day: 'Vendredi',
            isOpen: true,
            openTime: '09:00',
            closeTime: '19:00',
            hasLunchBreak: true,
            lunchStart: '12:00',
            lunchEnd: '13:00',
          ),
          BusinessHours(
            day: 'Samedi',
            isOpen: true,
            openTime: '10:00',
            closeTime: '18:00',
            hasLunchBreak: false,
          ),
          BusinessHours(
            day: 'Dimanche',
            isOpen: false,
          ),
        ],
      );
}
