import 'dart:convert';
import 'package:doctro_patient/const/app_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Payment/MedicinePayment.dart';
import '../../const/Palette.dart';
import '../../const/preference.dart';
import '../../database/db_service.dart';
import '../../database/form_helper.dart';
import '../../localization/localization_constant.dart';
import '../../models/data_model.dart';

class AddToCart extends StatefulWidget {
  final bool isEditMode = true;

  @override
  _AddToCartState createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  String? address = "";

  ProductModel? model;
  late DBService dbService;

  bool isSelected = false;

  int grandTotal = 0;
  int passGrandTotal = 0;

  int pharmacyId = 0;
  int? pharmacyIdCart = 0;
  String? prescriptionFilePath = "";

  List<ProductModel> products = [];
  List<Map<String, dynamic>> medicineBooked = [];

  int? shippingStatus;
  String? pharmacyLat = "";
  String? pharmacyLang = "";

  String? listOfMedicine;

  String? userLat = "";
  String? userLang = "";

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _getAddress();
    dbService = new DBService();
    model = new ProductModel();

    getGrandTotal();
  }

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  getGrandTotal() async {
    Future<List<ProductModel>> _futureOfList = dbService.getProducts();
    products.clear();
    products = await _futureOfList;
    if (products.length != 0) {
      if (products.length != 0) {
        medicineBooked.clear();

        shippingStatus = products[0].shippingStatus;
        pharmacyLat = products[0].pLat;
        pharmacyLang = products[0].pLang;
        grandTotal = 0;
        for (var data in products) {
          grandTotal = grandTotal + (data.quantity! * data.price!);
          Map<String, dynamic> medicineBookedDetail = {
            "id": data.medicineId.toString(),
            "price": data.price.toString(),
            "qty": data.quantity.toString(),
          };
          medicineBooked.add(medicineBookedDetail);
          pharmacyIdCart = products[0].pharmacyId;
          prescriptionFilePath = products[0].prescriptionFilePath;
          Logger().d(medicineBooked);
        }
        setState(() {});
      }
    }
  }

  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        address = (prefs.getString('Address'));
        userLat = (prefs.getString('lat'));
        userLang = (prefs.getString('lang'));
      },
    );
  }

  setBookedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (grandTotal != grandTotal) {
      prefs.remove('grandTotal');
      prefs.remove('pharmacyIdCart');
      prefs.remove('pharmacyLat');
      prefs.remove('pharmacyLang');
      prefs.setInt('grandTotal', grandTotal);
      prefs.setInt('pharmacyIdCart', pharmacyIdCart!);
      prefs.setString('prescriptionFilePath', prescriptionFilePath!);
      prefs.setString('pharmacyLat', pharmacyLat!);
      prefs.setString('pharmacyLang', pharmacyLang!);
      _saveToList(medicineBooked);
    } else {
      prefs.setInt('grandTotal', grandTotal);
      prefs.setInt('pharmacyIdCart', pharmacyIdCart!);
      prefs.setString('prescriptionFilePath', prescriptionFilePath!);
      prefs.setString('pharmacyLat', pharmacyLat!);
      prefs.setString('pharmacyLang', pharmacyLang!);
      _saveToList(medicineBooked);
    }
  }

  _saveToList(List<Map<String, dynamic>> _favList) async {
    var s = json.encode(medicineBooked);
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('myFavList', s);
    Logger().d(SharedPreferenceHelper.getString('myFavList'));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (products.length != 0) {
      return Scaffold(
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Palette.white,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Palette.dark_blue,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              getTranslated(context, AppString.cart_title).toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Palette.dark_blue,
              ),
            ),
            centerTitle: true),
        body: SingleChildScrollView(child: _fetchData()),
        bottomNavigationBar: Container(
          height: 100,
          child: Column(
            children: [
              Container(
                height: 50,
                width: width * 1,
                color: Palette.white,
                margin: EdgeInsets.only(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 30, right: 30),
                            child: Row(
                              children: [
                                Text(
                                  getTranslated(context, AppString.AddToCart_total).toString(),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Palette.dark_blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_right_alt_rounded,
                                  color: Palette.grey,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 30, left: 30),
                      child: Row(
                        children: [
                          Text(
                            '$grandTotal',
                            style: TextStyle(
                              fontSize: 15,
                              color: Palette.dark_blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                child: ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getTranslated(context, AppString.AddToCart_placeOrder).toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Palette.white,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    loggerNoStack.t(medicineBooked);
                    if (products.length != 0) {
                      setBookedData();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicinePayment(),
                        ),
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: getTranslated(context, AppString.AddToCart_cartInNoData).toString(),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Palette.white,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Palette.dark_blue,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              getTranslated(context, AppString.cart_title).toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Palette.dark_blue,
              ),
            ),
            centerTitle: true),
        body: Center(
          child: Text(
            getTranslated(context, AppString.AddToCart_NoData).toString(),
            style: TextStyle(fontSize: width * 0.045, color: Palette.grey, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  Widget _fetchData() {
    return FutureBuilder<List<ProductModel>>(
      future: dbService.getProducts(),
      builder: (BuildContext context, AsyncSnapshot<List<ProductModel>> products) {
        if (products.hasData) {
          return _buildUI(products.data!);
        }

        return SpinKitFadingCircle(
          color: Palette.blue,
          size: 50.0,
        );
      },
    );
  }

  Widget _buildUI(List<ProductModel> products) {
    List<Widget> widgets = [];

    widgets.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildDataTable(products)],
      ),
    );

    return Padding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
      padding: EdgeInsets.all(5),
    );
  }

  Widget _buildDataTable(List<ProductModel> model) {
    return DataTable(
      columnSpacing: 10,
      horizontalMargin: 5,
      columns: [
        DataColumn(
          label: Container(
            width: 110,
            alignment: Alignment.center,
            child: Text(
              getTranslated(context, AppString.AddToCart_medicineName).toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Palette.blue,
              ),
            ),
          ),
        ),
        DataColumn(
          label: Container(
            width: 80,
            alignment: Alignment.center,
            child: Text(
              getTranslated(context, AppString.AddToCart_quantity).toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Palette.blue,
              ),
            ),
          ),
        ),
        DataColumn(
          label: Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              getTranslated(context, AppString.AddToCart_price).toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Palette.blue,
              ),
            ),
          ),
        ),
        DataColumn(
          label: Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              getTranslated(context, AppString.AddToCart_total).toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Palette.blue,
              ),
            ),
          ),
        ),
        DataColumn(
          label: Container(
            width: 50,
            alignment: Alignment.center,
            child: Text(
              getTranslated(context, AppString.AddToCart_action).toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Palette.blue,
              ),
            ),
          ),
        ),
      ],
      sortColumnIndex: 1,
      rows: model
          .map(
            (data) => DataRow(
              selected: isSelected,
              cells: <DataCell>[
                DataCell(
                  Container(
                    width: 100,
                    alignment: Alignment.center,
                    child: Text(
                      data.productName!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Palette.dark_blue,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: Container(
                      height: 22,
                      width: 69,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Palette.dark_blue,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              decrease(data);
                            },
                            child: Container(
                              height: double.infinity,
                              color: Palette.blue,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 3, right: 3),
                                child: Icon(
                                  Icons.remove,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: double.infinity,
                            width: 25,
                            color: Palette.white,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 3, right: 3),
                              child: Center(
                                child: Text(
                                  data.quantity.toString(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.dark_blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              increase(data);
                            },
                            child: Container(
                              height: double.infinity,
                              color: Palette.blue,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 3, right: 3),
                                child: Icon(Icons.add_outlined, size: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      data.price.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Palette.dark_blue),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: 45,
                    alignment: Alignment.center,
                    child: Text(
                      (data.price! * data.quantity!).toString(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Palette.dark_blue),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: 45,
                    child: Center(
                      child: new IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(
                          Icons.clear,
                          color: Palette.dark_blue,
                          size: 20,
                        ),
                        onPressed: () {
                          FormHelper.showMessage(
                            context,
                            getTranslated(context, AppString.AddToCart_removeMedicine_alert_title).toString(),
                            getTranslated(context, AppString.AddToCart_removeMedicine_alert_text).toString(),
                            getTranslated(context, AppString.No).toString(),
                            () {
                              Navigator.of(context).pop();
                            },
                            buttonText2: getTranslated(context, AppString.Yes).toString(),
                            isConfirmationDialog: true,
                            onPressed2: () {
                              loading = true;
                              dbService.deleteProduct(data).then((value) {
                                setState(() {
                                  setState(() {
                                    loading = false;
                                    getGrandTotal();
                                  });
                                  Navigator.of(context).pop();
                                });
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  void increase(ProductModel data) {
    setState(
      () {
        if (data.quantity == data.medicineStock) {
          Fluttertoast.showToast(
            msg: getTranslated(context, AppString.AddToCart_outOfStock_toast).toString(),
          );
        } else {
          data.quantity = data.quantity! + 1;
          update(data);
        }
      },
    );
  }

  void decrease(ProductModel data) {
    setState(
      () {
        1 < data.quantity! ? data.quantity = data.quantity! - 1 : data.quantity = 1;
        update(data);
      },
    );
  }

  void update(ProductModel data) {
    if (widget.isEditMode) {
      dbService.updateProduct(data).then(
        (value) {
          setState(
            () {
              getGrandTotal();
            },
          );
        },
      );
    }
  }
}
