
import 'package:flutter/material.dart';
import 'dart:collection';

class MainTab extends StatefulWidget {
  const MainTab({Key? key}) : super(key: key);

  @override
  MyMainTab createState() => MyMainTab();
}

class MyMainTab extends State<MainTab> { 
  HashSet selectItems = new HashSet();
  bool isMultiSelectionEnabled = false;
  int initPosition = 0;
  int selectedCard = -1;
  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      body: SafeArea(
        child: CustomTabView(
          initPosition: initPosition,
          itemCount: arg['tabs'].length,
          tabBuilder: (context, index) =>
              Tab(text: arg['tabs'][index]['title']),
          pageBuilder: (context, index) => Container(
              child: GridView.builder(
                  shrinkWrap: false,
                  scrollDirection: Axis.vertical,
                  itemCount: arg['tabs'][index]['list'].length,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 3),
                  ),
                  itemBuilder: (BuildContext context, int index1) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          // Ontap of each card, set the defined int to the grid view index
                          selectedCard = index1;
                        });
                      },
                      child: Card(
                        // Check if the index is equal to the selected Card integer
                        color:
                            selectedCard == index1 ? Colors.blue : Colors.amber,
                        child: Container(
                            // height: 200,
                            width: 200,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    arg['tabs'][index]['list'][index1]
                                        ['productPicture'],
                                    //fit: BoxFit.cover,
                                    //height: 200.0,
                                    width: 200,
                                  ),
                                ),
                              ],
                            )),
                      ),
                    );  
                  })),
          onPositionChange: (index) {
            initPosition = index;
          },
          onScroll: (position) => print('$position'),
        ),
      ),
    );
  }

  String getSelectedItemCount() {
    return selectItems.isNotEmpty
        ? selectItems.length.toString() + " item selected"
        : "No item selected";
  }

  void doMultiSelection(String path) {
    if (isMultiSelectionEnabled) {
      setState(() {
        if (selectItems.contains(path)) {
          selectItems.remove(path);
        } else {
          selectItems.add(path);
        }
      });
    } else {
      //
    }
  }

  GridTile getGridItem(String data, String price, String img) {
    return GridTile(
      child: InkWell(
        onTap: () {
          isMultiSelectionEnabled = true;
          //doMultiSelection(path);
          print('click me here::2022$data["keys"]');
        },
        onLongPress: () {
          isMultiSelectionEnabled = true;
          //doMultiSelection(path);
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                img,
                //fit: BoxFit.cover,
                height: 200.0,
                // width: 150.0,
              ),
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Container(
                color: Colors.grey.withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data,
                        style: TextStyle(color: Colors.white, fontSize: 17)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$$price',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600)),
                        IconButton(
                            onPressed: () {
                              print('click me');
                            },
                            icon: Icon(
                              Icons.add_circle,
                              color: Colors.white,
                              size: 35,
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),
            Visibility(
                visible: selectItems.contains(''),
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 30,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class CustomTabView extends StatefulWidget {
  const CustomTabView({
    Key? key,
    required this.itemCount,
    required this.tabBuilder,
    required this.pageBuilder,
    this.stub,
    this.onPositionChange,
    this.onScroll,
    this.initPosition,
  }) : super(key: key);

  final int itemCount;
  final IndexedWidgetBuilder tabBuilder;
  final IndexedWidgetBuilder pageBuilder;
  final Widget? stub;
  final ValueChanged<int>? onPositionChange;
  final ValueChanged<double>? onScroll;
  final int? initPosition;

  @override
  CustomTabsState createState() => CustomTabsState();
}

class CustomTabsState extends State<CustomTabView>
    with TickerProviderStateMixin {
  late TabController controller;
  late int _currentCount;
  late int _currentPosition;

  @override
  void initState() {
    _currentPosition = widget.initPosition ?? 0;
    controller = TabController(
      length: widget.itemCount,
      vsync: this,
      initialIndex: _currentPosition,
    );
    controller.addListener(onPositionChange);
    controller.animation!.addListener(onScroll);
    _currentCount = widget.itemCount;
    super.initState();
  }

  @override
  void didUpdateWidget(CustomTabView oldWidget) {
    if (_currentCount != widget.itemCount) {
      controller.animation!.removeListener(onScroll);
      controller.removeListener(onPositionChange);
      controller.dispose();

      if (widget.initPosition != null) {
        _currentPosition = widget.initPosition!;
      }

      if (_currentPosition > widget.itemCount - 1) {
        _currentPosition = widget.itemCount - 1;
        _currentPosition = _currentPosition < 0 ? 0 : _currentPosition;
        if (widget.onPositionChange is ValueChanged<int>) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && widget.onPositionChange != null) {
              widget.onPositionChange!(_currentPosition);
            }
          });
        }
      }

      _currentCount = widget.itemCount;
      setState(() {
        controller = TabController(
          length: widget.itemCount,
          vsync: this,
          initialIndex: _currentPosition,
        );
        controller.addListener(onPositionChange);
        controller.animation!.addListener(onScroll);
      });
    } else if (widget.initPosition != null) {
      controller.animateTo(widget.initPosition!);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.animation!.removeListener(onScroll);
    controller.removeListener(onPositionChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount < 1) return widget.stub ?? Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
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
              widget.itemCount,
              (index) => widget.tabBuilder(context, index),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
            children: List.generate(
              widget.itemCount,
              (index) => widget.pageBuilder(context, index),
            ),
          ),
        ),
      ],
    );
  }

  void onPositionChange() {
    if (!controller.indexIsChanging) {
      _currentPosition = controller.index;
      if (widget.onPositionChange is ValueChanged<int>) {
        widget.onPositionChange!(_currentPosition);
      }
    }
  }

  void onScroll() {
    if (widget.onScroll is ValueChanged<double>) {
      widget.onScroll!(controller.animation!.value);
    }
  }
}
