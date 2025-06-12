import 'package:url_launcher/url_launcher.dart';

class PaymentApiService {
  final String _midtransPaymentUrl = 'https://app.midtrans.com/payment-links/1749740565138';

  String getMidtransPaymentUrl() {
    return _midtransPaymentUrl;
  }

  Future<void> launchMidtransPayment() async {
    final Uri url = Uri.parse(_midtransPaymentUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $_midtransPaymentUrl';
    }
  }
}
