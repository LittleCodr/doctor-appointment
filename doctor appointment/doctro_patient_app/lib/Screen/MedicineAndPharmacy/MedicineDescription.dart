import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api/network_api.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../database/db_service.dart';
import '../../../database/form_helper.dart';
import '../../../models/data_model.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/medicine_details_model.dart';

class MedicineDescription extends StatefulWidget {
  final int? id;

  MedicineDescription({this.id});

  @override
  _MedicineDescriptionState createState() => _MedicineDescriptionState();
}

class _MedicineDescriptionState extends State<MedicineDescription> {
  bool loading = false;

  ProductModel? model;
  late DBService dbService;

  bool visibility = true;

  late PlatformFile file;

  String fileName = "";
  String filePath = "";

  int? id = 0;
  int? medicineId = 0;
  String? medicineName = "";
  int? medicinePricePrStrip = 0;
  String? medicineDescription = "";
  String? medicineWorks = "";
  String? medicineImage = "";
  int? medicineNumberOfMedicine = 0;
  int? medicineTotalStock = 0;
  int quantity = 1;
  int? prescriptionRequired = 0;

  int? pharamacyId = 0;

  int? listOfPharmacyId = 0;
  int? shippingStatus;
  String? pharmacyLat = "";
  String? pharmacyLang = "";
  List<String>? minValue = [];
  List<String>? maxValue = [];
  List<String>? charges = [];

  bool isInCart = false;

  String name = "";
  String price = "";

  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();
    id = widget.id;
    callApiMedicine();
    dbService = new DBService();
    model = new ProductModel();

    _getPharamacyId();
  }

  _getPharamacyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        pharamacyId = prefs.getInt('pharamacyId');
        shippingStatus = prefs.getInt('ShippingStatus');
        pharmacyLat = prefs.getString('pharmacyLat');
        pharmacyLang = prefs.getString('pharmacyLang');
        minValue = prefs.getStringList('minValue');
        maxValue = prefs.getStringList('maxValue');
        charges = prefs.getStringList('charges');
      },
    );
  }

  _getCardPharmacyId() async {
    Future<List<ProductModel>> _futureOfList = dbService.getProducts();
    products.clear();
    products = await _futureOfList;
    if (products.length != 0) {
      listOfPharmacyId = products[0].pharmacyId;
      for (int i = 0; i < products.length; i++) {
        if (products[i].medicineId == medicineId) {
          setState(() {
            isInCart = true;
            visibility = false;
          });
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.blue,
        size: 50.0,
      ),
      child: Scaffold(
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
            '$medicineName',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Palette.blue,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'AddToCart');
                },
                icon: (Icon(
                  Icons.shopping_cart_outlined,
                  color: Palette.blue,
                )),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: width * 1,
                height: height * 0.25,
                child: Row(
                  children: [
                    Container(
                      width: width * 0.3,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: CachedNetworkImage(
                        alignment: Alignment.center,
                        imageUrl: '$medicineImage',
                        placeholder: (context, url) => SpinKitFadingCircle(
                          color: Palette.blue,
                        ),
                        errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                      ),
                    ),
                    Container(
                      width: width * 0.55,
                      margin: EdgeInsets.symmetric(vertical: 25, horizontal: 0),
                      child: Column(
                        children: [
                          Container(
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              '$medicineName',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                          Container(
                            alignment: AlignmentDirectional.topStart,
                            margin: EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                            child: Row(
                              children: [
                                Container(
                                  child: Text(
                                    getTranslated(context, AppString.medicineDescription_price).toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Palette.dark_blue,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$medicinePricePrStrip ' + '/ ' + getTranslated(context, AppString.medicineDescription_strip).toString(),
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Palette.blue),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            alignment: AlignmentDirectional.topStart,
                            margin: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                            child: Row(
                              children: [
                                Container(
                                  child: Text(
                                    getTranslated(context, AppString.medicineDescription_strip1).toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Palette.dark_blue,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    '$medicineNumberOfMedicine ' + getTranslated(context, AppString.medicineDescription_tablet).toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Palette.blue,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            alignment: AlignmentDirectional.topStart,
                            height: 28,
                            child: Container(
                              width: width * 0.26,
                              decoration: BoxDecoration(border: Border.all(color: Palette.dark_blue), borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      decrease();
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      // color: Palette.blue,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5, right: 5),
                                        child: Icon(
                                          Icons.remove,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: double.infinity,
                                    width: 30,
                                    color: Palette.white,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5, right: 5),
                                      child: Center(
                                        child: Text(
                                          '$quantity',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Palette.dark_blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      increase();
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      // color: Palette.blue,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5, right: 5),
                                        child: Icon(Icons.add_outlined, size: 25),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: Column(
                  children: [
                    DottedLine(
                      direction: Axis.horizontal,
                      lineLength: double.infinity,
                      lineThickness: 1.0,
                      dashLength: 4.0,
                      dashColor: Palette.blue,
                      dashRadius: 0.0,
                      dashGapLength: 4.0,
                      dashGapColor: Palette.transparent,
                      dashGapRadius: 0.0,
                    )
                  ],
                ),
              ),
              Container(
                alignment: AlignmentDirectional.topStart,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  getTranslated(context,AppString. medicineDescription_description).toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Palette.dark_blue,
                  ),
                ),
              ),
              Container(
                alignment: AlignmentDirectional.topStart,
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Html(
                  data: "$medicineDescription",
                ),
              ),
              Container(
                alignment: AlignmentDirectional.topStart,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  getTranslated(context,AppString. medicineDescription_howItWork).toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Palette.dark_blue,
                  ),
                ),
              ),
              Container(
                alignment: AlignmentDirectional.topStart,
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Html(
                  data: "$medicineWorks",
                ),
              ),
              prescriptionRequired == 1
                  ? Column(
                      children: [
                        Container(
                          child: Text(
                            getTranslated(context,AppString. medicineDescription_addPrescriptionPdf).toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Palette.dark_blue,
                            ),
                          ),
                        ),
                        fileName != ""
                            ? Container(
                                child: Text(
                                  fileName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Palette.dark_blue,
                                  ),
                                ),
                              )
                            : Container(),
                        Container(
                          child: fileName != ""
                              ? ElevatedButton(
                                  child: Text(
                                    getTranslated(context, AppString.medicineDescription_selected).toString(),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Palette.dark_grey),
                                  ),
                                  onPressed: () {},
                                )
                              : ElevatedButton(
                                  child: Text(
                                    getTranslated(context, AppString.medicineDescription_selectPdf).toString(),
                                  ),
                                  onPressed: () {
                                    filePicker();
                                  },
                                ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: height * 0.05,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: visibility == true ? Palette.blue : Palette.dark_grey,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                visibility == true
                    ? Text(
                        getTranslated(context, AppString.medicineDescription_addToCart_button).toString(),
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: Palette.white,
                        ),
                      )
                    : Text(
                        getTranslated(context, AppString.medicineDescription_viewCart_button).toString(),
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: Palette.white,
                        ),
                      ),
              ],
            ),
            onPressed: () {
              if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
                if (prescriptionRequired == 0) {
                  if (visibility == true && isInCart == false) {
                    if (pharamacyId == listOfPharmacyId || listOfPharmacyId == 0) {
                      setState(() {
                        visibility = false;
                      });
                      this.model!.productName = medicineName;
                      this.model!.medicineId = medicineId;
                      this.model!.quantity = quantity;
                      this.model!.price = medicinePricePrStrip;
                      this.model!.pharmacyId = pharamacyId;
                      this.model!.shippingStatus = shippingStatus;
                      this.model!.pLat = pharmacyLat;
                      this.model!.pLang = pharmacyLang;
                      this.model!.prescriptionFilePath = filePath;
                      this.model!.medicineStock = medicineTotalStock;

                      dbService.addProduct(model).then(
                        (value) {
                          Fluttertoast.showToast(
                            msg: getTranslated(context, AppString.medicineDescription_medicineAddToCart_toast).toString(),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        },
                      );
                    } else {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(getTranslated(context, AppString.medicineDescription_clearCartDetail_alert_title).toString()),
                          content: Text(getTranslated(context, AppString.medicineDescription_clearCartDetail_alert_text).toString()),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Text(getTranslated(context, AppString.cancel).toString()),
                            ),
                            TextButton(
                              onPressed: () async {
                                late List<ProductModel> products;
                                await dbService.getProducts().then((value) {
                                  products = value;
                                });
                                assert(products.isNotEmpty);
                                dbService.deleteTable(products[0]).then((value) {
                                  setState(() {
                                    listOfPharmacyId = 0;
                                    if (visibility == true) {
                                      if (listOfPharmacyId == 0) {
                                        setState(() {
                                          visibility = false;
                                        });
                                        this.model!.productName = medicineName;
                                        this.model!.medicineId = medicineId;
                                        this.model!.quantity = quantity;
                                        this.model!.price = medicinePricePrStrip;
                                        this.model!.pharmacyId = pharamacyId;
                                        this.model!.shippingStatus = shippingStatus;
                                        this.model!.pLat = pharmacyLat;
                                        this.model!.pLang = pharmacyLang;
                                        this.model!.prescriptionFilePath = filePath;
                                        this.model!.medicineStock = medicineTotalStock;

                                        dbService.addProduct(model).then(
                                          (value) {
                                            Fluttertoast.showToast(
                                              msg: getTranslated(context, AppString.medicineDescription_medicineAddToCart_toast).toString(),
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                            );
                                          },
                                        );
                                      }
                                    }
                                    Navigator.of(context).pop();
                                  });
                                });
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    Navigator.pushNamed(context, 'AddToCart');

                    ///
                    quantity = 1;
                    setState(() {});
                  }
                } else if (prescriptionRequired == 1 && fileName != "") {
                  if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
                    if (visibility == true && isInCart == false) {
                      if (pharamacyId == listOfPharmacyId || listOfPharmacyId == 0) {
                        setState(() {
                          visibility = false;
                        });
                        this.model!.productName = medicineName;
                        this.model!.medicineId = medicineId;
                        this.model!.quantity = quantity;
                        this.model!.price = medicinePricePrStrip;
                        this.model!.pharmacyId = pharamacyId;
                        this.model!.shippingStatus = shippingStatus;
                        this.model!.pLat = pharmacyLat;
                        this.model!.pLang = pharmacyLang;
                        this.model!.prescriptionFilePath = filePath;
                        this.model!.medicineStock = medicineTotalStock;

                        dbService.addProduct(model).then(
                          (value) {
                            Fluttertoast.showToast(
                              msg: getTranslated(context, AppString.medicineDescription_medicineAddToCart_toast).toString(),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                          },
                        );
                      } else {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text(
                              getTranslated(context, AppString.medicineDescription_clearCartDetail_alert_title).toString(),
                            ),
                            content: Text(
                              getTranslated(context, AppString.medicineDescription_clearCartDetail_alert_text).toString(),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    Navigator.of(context).pop();
                                  });
                                },
                                child: Text(
                                  getTranslated(context, AppString.cancel).toString(),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  late List<ProductModel> products;
                                  await dbService.getProducts().then((value) {
                                    products = value;
                                  });
                                  assert(products.isNotEmpty);
                                  dbService.deleteTable(products[0]).then((value) {
                                    setState(() {
                                      listOfPharmacyId = 0;
                                      if (visibility == true) {
                                        if (listOfPharmacyId == 0) {
                                          setState(() {
                                            visibility = false;
                                          });
                                          this.model!.productName = medicineName;
                                          this.model!.medicineId = medicineId;
                                          this.model!.quantity = quantity;
                                          this.model!.price = medicinePricePrStrip;
                                          this.model!.pharmacyId = pharamacyId;
                                          this.model!.shippingStatus = shippingStatus;
                                          this.model!.pLat = pharmacyLat;
                                          this.model!.pLang = pharmacyLang;
                                          this.model!.prescriptionFilePath = filePath;
                                          this.model!.medicineStock = medicineTotalStock;
                                          dbService.addProduct(model).then(
                                            (value) {
                                              Fluttertoast.showToast(
                                                msg: getTranslated(context, AppString.medicineDescription_medicineAddToCart_toast).toString(),
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                              );
                                            },
                                          );
                                        }
                                      }
                                      Navigator.of(context).pop();
                                    });
                                  });
                                },
                                child: Text(
                                  getTranslated(context, AppString.medicineDescription_oK).toString(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      Navigator.pushNamed(context, 'AddToCart');

                      ///
                      quantity = 1;
                      setState(() {});
                    }
                  } else {
                    FormHelper.showMessage(
                      context,
                      getTranslated(context, AppString.medicineDescription_buyMedicine_alert_title).toString(),
                      getTranslated(context, AppString.medicineDescription_buyMedicine_alert_text).toString(),
                      getTranslated(context, AppString.medicineDescription_cancel).toString(),
                      () {
                        Navigator.of(context).pop();
                      },
                      buttonText2: getTranslated(context, AppString.login).toString(),
                      isConfirmationDialog: true,
                      onPressed2: () {
                        Navigator.pushNamed(context, 'SignIn');
                      },
                    );
                  }
                } else if (prescriptionRequired == 1 && fileName == "") {
                  Fluttertoast.showToast(
                    msg: getTranslated(context, AppString.medicineDescription_pleaseSelectPdf_toast).toString(),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Palette.blue,
                    textColor: Palette.white,
                  );
                }
              } else {
                FormHelper.showMessage(
                  context,
                  getTranslated(context, AppString.medicineDescription_buyMedicine_alert_title).toString(),
                  getTranslated(context, AppString.medicineDescription_buyMedicine_alert_text).toString(),
                  getTranslated(context, AppString.medicineDescription_cancel).toString(),
                  () {
                    Navigator.of(context).pop();
                  },
                  buttonText2: getTranslated(context, AppString.login).toString(),
                  isConfirmationDialog: true,
                  onPressed2: () {
                    Navigator.pushNamed(context, 'SignIn');
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  filePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      file = result.files.first;

      if (file.extension != "pdf") {
        print("PDF ${file.extension}");
        Fluttertoast.showToast(msg: "File Invalid", toastLength: Toast.LENGTH_SHORT);
      } else {
        setState(() {
          fileName = file.name;
        });
      }
    } else {
      print('User canceled the picker');
    }
  }

  void increase() {
    setState(() {
      if (quantity == medicineTotalStock) {
        Fluttertoast.showToast(msg: getTranslated(context, AppString.medicineDescription_outOfStock_toast).toString());
      } else {
        quantity = quantity + 1;
      }
    });
  }

  void decrease() {
    setState(() {
      quantity == 1 ? quantity = 1 : quantity = quantity - 1;
    });
  }

  Future<BaseModel<MedicineDetails>> callApiMedicine() async {
    MedicineDetails response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).medicineDetails(id);
      setState(() {
        if (response.success == true) {
          setState(
            () {
              loading = false;
              medicineId = response.data!.id;
              medicineName = response.data!.name;
              medicinePricePrStrip = response.data!.pricePrStrip;
              medicineDescription = response.data!.description;
              medicineWorks = response.data!.works;
              medicineNumberOfMedicine = response.data!.numberOfMedicine;
              medicineImage = response.data!.fullImage;
              medicineTotalStock = response.data!.totalStock;
              prescriptionRequired = response.data!.prescriptionRequired;
              _getCardPharmacyId();
            },
          );
        }
      });
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
