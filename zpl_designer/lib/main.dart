import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpl_designer/core/app_theme.dart';
import 'package:zpl_designer/core/dpmm.dart';
import 'package:zpl_designer/provider/canvas_config_provider.dart';
import 'package:zpl_designer/provider/editor_state_provider.dart';
import 'package:zpl_designer/view/design_view.dart';

void main() {
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CanvasConfigProvider(
            widthMm: 100,
            heightMm: 100,
            dpmm: Dpmm.dpmm8,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EditorStateProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'ZPL Designer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const DesignView(),
      ),
    );
  }
}
