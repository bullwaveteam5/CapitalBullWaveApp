class InvestmentPlanModel {
  final String id;
  final String name;
  final double minimumInvestment;
  final double monthlyReturnRate;
  final double annualReturnRate;
  final String description;
  final bool isFeatured;

  const InvestmentPlanModel({
    required this.id,
    required this.name,
    required this.minimumInvestment,
    required this.monthlyReturnRate,
    required this.annualReturnRate,
    required this.description,
    this.isFeatured = false,
  });
}

class InvestmentDetailModel {
  final String id;
  final double amount;
  final DateTime date;
  final double monthlyReturn;
  final String status;
  final List<String> documents;

  const InvestmentDetailModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.monthlyReturn,
    required this.status,
    required this.documents,
  });
}

class FaqItem {
  final String question;
  final String answer;
  final bool isExpanded;

  FaqItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });

  FaqItem copyWith({bool? isExpanded}) => FaqItem(
        question: question,
        answer: answer,
        isExpanded: isExpanded ?? this.isExpanded,
      );
}
