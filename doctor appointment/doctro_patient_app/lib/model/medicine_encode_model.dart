class MedicineEncode {
  int? _id;
  int? _price;
  int? _qty;

  get id => _id;

  set id(id) {
    _id = id;
  }

  get price => _price;

  set price(price) {
    _price = price;
  }

  get qty => _qty;

  set qty(qty) {
    _qty = qty;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['price'] = this.price;
    data['qty'] = this.qty;
    return data;
  }
}
