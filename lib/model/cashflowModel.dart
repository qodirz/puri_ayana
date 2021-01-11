
class CashflowModel {
  CashflowModel({
      this.id,
      this.cashIn,
      this.cashOut,
      this.total,
      this.month,
      this.year,
      this.createdAt,
      this.updatedAt,
  });

  int id;
  double cashIn;
  double cashOut;
  double total;
  String month;
  int year;
  DateTime createdAt;
  DateTime updatedAt;

  factory CashflowModel.fromJson(Map<String, dynamic> json) {
    print("CashFlow from model");
    print(json);
    return CashflowModel(
      id: json["id"],
      cashIn: json["cash_in"],
      cashOut: json["cash_out"],
      total: json["total"],
      month: json["month_info"],
      year: json["year"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
    );
  }    
}