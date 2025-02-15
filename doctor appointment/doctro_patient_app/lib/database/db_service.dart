import 'package:doctro_patient/models/data_model.dart';

import 'db_helper.dart';

class DBService {
  Future<bool> addProduct(ProductModel? model) async {
    await DB.init();
    bool isSaved = false;
    if (model != null) {
      int inserted = await DB.insert(ProductModel.table, model);
      isSaved = inserted == 1 ? true : false;
    }
    return isSaved;
  }

  Future<bool> updateProduct(ProductModel model) async {
    await DB.init();
    bool isSaved = false;
    if (model.id != null) {
      int inserted = await DB.update(ProductModel.table, model);

      isSaved = inserted == 1 ? true : false;
    }
    return isSaved;
  }

  Future<List<ProductModel>> getProducts() async {
    await DB.init();
    List<Map<String, dynamic>> products = await DB.query(ProductModel.table);

    return products.map((item) => ProductModel.fromMap(item)).toList();
  }

  Future<bool> deleteProduct(ProductModel model) async {
    await DB.init();
    bool isSaved = false;
    if (model.id != null) {
      int inserted = await DB.delete(ProductModel.table, model);

      isSaved = inserted == 1 ? true : false;
    }

    return isSaved;
  }

  Future<bool> deleteTable(ProductModel model) async {
    await DB.init();
    bool isSaved = false;
    if (model.id != null) {
      int inserted = await DB.deleteTable(ProductModel.table, model);

      isSaved = inserted == 1 ? true : false;
    }

    return isSaved;
  }
}
