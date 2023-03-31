import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/Customers/add_customer.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../GlobalComponents/button_global.dart';
import '../../constant.dart';

class AddItem extends StatefulWidget {
  final List listProduct;
  const AddItem({Key? key, required this.listProduct}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddItme createState() => _AddItme();
}

class _AddItme extends State<AddItem> with SingleTickerProviderStateMixin {
  final TextEditingController proNameController = TextEditingController();
  String searching = '';
  int selectedCard = -1;
  late TabController controller;

  @override
  void initState() {
    controller = TabController(
      length: widget.listProduct.length,
      vsync: this,
      initialIndex: 0,
    );
    log(widget.listProduct);
    super.initState();
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    if (barcodeScanRes != '-1') {
      setState(() {
        searching = barcodeScanRes;
      });
      proNameController.text = barcodeScanRes;
    }
  }

  @override
  Widget build(BuildContext context) {
    //final arg = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Add Items',
          style: GoogleFonts.poppins(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: kGreyTextColor),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pushNamed(context, '/salesCustomer',
                              arguments: {'from': 'pos'});
                        },
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 10.0,
                            ),
                            Text('Select Customer Name'),
                            Spacer(),
                            Icon(Icons.keyboard_arrow_down),
                            SizedBox(
                              width: 10.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        const AddCustomer().launch(context);
                      },
                      child: Container(
                        height: 55.0,
                        width: 100.0,
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: kGreyTextColor),
                        ),
                        child: const Image(
                          image: AssetImage('images/pos_user_add.png'),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                          height: 55,
                          child: TextField(
                            onChanged: (txt) {
                              setState(() {
                                searching = txt;
                              });
                            },
                            controller: proNameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Searching...',
                              hintText: 'Enter name or barcode',
                            ),
                          )),
                    )),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () => scanBarcodeNormal(),
                      child: Container(
                        height: 55.0,
                        width: 100.0,
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: kGreyTextColor),
                        ),
                        child: const Image(
                          image: AssetImage('images/pos_qr.png'),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: TabBar(
                isScrollable: true,
                controller: controller,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Theme.of(context).hintColor,
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                tabs: List.generate(
                  widget.listProduct.length,
                  (index) => Tab(text: widget.listProduct[index]['title']),
                ),
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(10),
              child: TabBarView(
                controller: controller,
                children: List.generate(
                  widget.listProduct.length,
                  (index) => GridView.builder(
                      shrinkWrap: false,
                      scrollDirection: Axis.vertical,
                      itemCount: widget.listProduct[index]["list"].length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.height / 3),
                      ),
                      itemBuilder: (BuildContext context, int index1) {
                        return GestureDetector(
                            onTap: () {},
                            child: Card(
                              color: selectedCard == index1
                                  ? Colors.blue
                                  : Colors.amber,
                              child: SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.network(
                                          widget.listProduct[index]['list']
                                              [index1]['productPicture'],
                                          //fit: BoxFit.cover,
                                          //height: 200.0,
                                          //width: 200,
                                        ),
                                      ),
                                    ],
                                  )),
                            ));
                      }),
                ),
              ),
            )),
          ],
        ),
      ),
      bottomNavigationBar: ButtonGlobal(
          iconWidget: null,
          buttontext: 'Continue(\$100)',
          iconColor: Colors.white,
          buttonDecoration: kButtonDecoration.copyWith(color: primaryColor),
          onPressed: () {
            Navigator.pushNamed(context, '/AddProducts');
          }),
    );
  }
}
