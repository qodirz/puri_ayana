class ContributionModel {
  ContributionModel({
      this.id,
      this.year,
      this.month,
      this.contribution,
      this.payAt,
      this.receiverId,
      this.paymentType,
      this.contributionDesc,
      this.createdAt,
      this.updatedAt,
      this.addressId,
      this.blok,
      this.importedCashTransaction,
  });

  int id;
  int year;
  dynamic month;
  double contribution;
  dynamic payAt;
  int receiverId;
  int paymentType;
  dynamic contributionDesc;
  DateTime createdAt;
  DateTime updatedAt;
  int addressId;
  dynamic blok;
  bool importedCashTransaction;

  factory ContributionModel.fromJson(Map<String, dynamic> json) => ContributionModel(
      id: json["id"],
      year: json["year"],
      month: json["month"],
      contribution: json["contribution"],
      payAt: json["tgl_bayar"],
      receiverId: json["receiver_id"],
      paymentType: json["payment_type"],
      contributionDesc: json["contribution_desc"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      addressId: json["address_id"],
      blok: json["blok"],
      importedCashTransaction: json["imported_cash_transaction"],
  );
    
}