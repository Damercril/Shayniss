import 'package:flutter_stripe/flutter_stripe.dart';
import '../models/transaction.dart';
import 'package:uuid/uuid.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  Future<Transaction> processPayment({
    required String clientId,
    required String clientName,
    required double amount,
    required List<String> services,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      late String? stripePaymentId;
      late TransactionStatus status;

      switch (paymentMethod) {
        case PaymentMethod.card:
          // Créer l'intention de paiement avec Stripe
          final paymentIntent = await _createPaymentIntent(amount);
          stripePaymentId = paymentIntent['id'];
          
          // Afficher l'interface de paiement Stripe
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent['client_secret'],
              merchantDisplayName: 'Shayniss',
              style: ThemeMode.light,
            ),
          );

          // Présenter la feuille de paiement
          await Stripe.instance.presentPaymentSheet();
          status = TransactionStatus.completed;
          break;

        case PaymentMethod.cash:
          // Pour le paiement en espèces, marquer comme complété immédiatement
          status = TransactionStatus.completed;
          stripePaymentId = null;
          break;

        case PaymentMethod.bankTransfer:
          // Pour le virement, marquer comme en attente
          status = TransactionStatus.pending;
          stripePaymentId = null;
          break;
      }

      // Créer la transaction
      final transaction = Transaction(
        clientId: clientId,
        clientName: clientName,
        amount: amount,
        date: DateTime.now(),
        services: services,
        status: status,
        paymentMethod: paymentMethod,
        stripePaymentId: stripePaymentId,
      );

      // TODO: Sauvegarder la transaction dans la base de données

      // Générer et sauvegarder la facture
      final invoiceUrl = await _generateInvoice(transaction);
      
      return transaction;
    } catch (e) {
      // En cas d'erreur, créer une transaction échouée
      return Transaction(
        clientId: clientId,
        clientName: clientName,
        amount: amount,
        date: DateTime.now(),
        services: services,
        status: TransactionStatus.failed,
        paymentMethod: paymentMethod,
      );
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent(double amount) async {
    // TODO: Implémenter la création de l'intention de paiement avec votre backend
    throw UnimplementedError();
  }

  Future<String> _generateInvoice(Transaction transaction) async {
    // TODO: Implémenter la génération de facture
    throw UnimplementedError();
  }

  Future<void> refundPayment(Transaction transaction) async {
    // TODO: Implémenter le remboursement
    throw UnimplementedError();
  }
}
