import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';

class DeviceFrameWrapper extends StatefulWidget {
  const DeviceFrameWrapper({super.key, required this.child});

  final Widget child;

  @override
  _DeviceFrameWrapperState createState() => _DeviceFrameWrapperState();
}

class _DeviceFrameWrapperState extends State<DeviceFrameWrapper> {
  bool isDark = true;
  bool isFrameVisible = true;
  bool isKeyboard = false;
  bool isEnabled = true;

  final GlobalKey screenKey = GlobalKey();

  Orientation orientation = Orientation.portrait;
  Widget _frame(DeviceInfo device) => Center(
        child: DeviceFrame(
          device: device,
          isFrameVisible: isFrameVisible,
          orientation: orientation,
          screen: Container(
            color: Colors.blue,
            child: VirtualKeyboard(
              isEnabled: isKeyboard,
              child: widget.child,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DeviceFrameTheme(
      style: DeviceFrameStyle.dark(),
      child: MaterialApp(
        title: 'Device Frames',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: DefaultTabController(
          length: Devices.all.length,
          child: Scaffold(
            backgroundColor: isDark ? Colors.white : Colors.black,
            appBar: AppBar(
              title: const Text('Device Frames'),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    setState(() {
                      isFrameVisible = !isFrameVisible;
                    });
                  },
                  icon: const Icon(Icons.settings_brightness),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isDark = !isDark;
                    });
                  },
                  icon: const Icon(Icons.brightness_medium),
                ),
                IconButton(
                  onPressed: () {
                    setState(
                      () {
                        orientation = orientation == Orientation.landscape
                            ? Orientation.portrait
                            : Orientation.landscape;
                      },
                    );
                  },
                  icon: const Icon(Icons.rotate_90_degrees_ccw),
                ),
                IconButton(
                  onPressed: () {
                    setState(
                      () {
                        isKeyboard = !isKeyboard;
                      },
                    );
                  },
                  icon: const Icon(Icons.keyboard),
                ),
                /*IconButton(
                  onPressed: () {
                    setState(() {
                      isEnabled = !isEnabled;
                    });
                  },
                  icon: Icon(Icons.check),
                ),*/
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  ...Devices.android.all.map(
                    (x) => Tab(
                      text: '${x.identifier.type} ${x.name}',
                    ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Builder(
                  builder: (context) => !isEnabled
                      ? widget.child
                      : AnimatedBuilder(
                          animation: DefaultTabController.of(context)!,
                          builder: (context, _) => _frame(
                            Devices.all[DefaultTabController.of(context)!.index],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
