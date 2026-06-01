import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

@RoutePage()
class GestureRecognizersPage extends StatefulWidget {
  const GestureRecognizersPage({super.key});

  @override
  State<GestureRecognizersPage> createState() => _GestureRecognizersPageState();
}

class _GestureRecognizersPageState extends State<GestureRecognizersPage> {
  // === Tap ===
  String _tapResult = '等待点击...';

  // === Drag ===
  Offset _dragOffset = Offset.zero;
  String _dragState = '等待拖拽...';

  // === Scale ===
  double _scale = 1.0;
  double _rotation = 0.0;

  // === LongPress ===
  String _longPressResult = '等待长按...';

  // === RawGestureDetector ===
  String _rawResult = '等待操作...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1.2 手势识别器')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====== Tap 手势 ======
          _SectionTitle('Tap 手势识别器'),
          const _ExplainText(
            'GestureDetector 的 onTap/onDoubleTap/onTapDown/onTapUp/onTapCancel\n'
            '底层由 TapGestureRecognizer 实现，支持单击、双击、长按后的点击。',
          ),
          GestureDetector(
            onTap: () => setState(() => _tapResult = '✅ onTap 单击'),
            onDoubleTap: () => setState(() => _tapResult = '✅ onDoubleTap 双击'),
            onTapDown: (d) => setState(() => _tapResult = '⬇️ onTapDown ${d.localPosition}'),
            onTapUp: (d) => setState(() => _tapResult = '⬆️ onTapUp ${d.localPosition}'),
            onTapCancel: () => setState(() => _tapResult = '❌ onTapCancel'),
            child: Container(
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_tapResult, style: const TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 24),

          // ====== Drag 手势 ======
          _SectionTitle('Drag 手势识别器'),
          const _ExplainText(
            'onPanStart / onPanUpdate / onPanEnd — 自由拖拽\n'
            'onHorizontalDragStart / onVerticalStart — 方向锁定拖拽\n'
            '⚠️ Pan 和 Scale 不能同时使用，会冲突！',
          ),
          GestureDetector(
            onPanStart: (d) => setState(() {
              _dragState = '🔄 拖拽开始';
            }),
            onPanUpdate: (d) => setState(() {
              _dragOffset += d.delta;
              _dragState = '🔄 拖拽中 dx=${_dragOffset.dx.toStringAsFixed(0)} dy=${_dragOffset.dy.toStringAsFixed(0)}';
            }),
            onPanEnd: (d) => setState(() {
              _dragState = '✅ 拖拽结束 velocity=${d.velocity.pixelsPerSecond.dx.toStringAsFixed(0)}';
            }),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 50 + _dragOffset.dx.clamp(-50.0, 200.0),
                    top: 50 + _dragOffset.dy.clamp(-30.0, 70.0),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Text('拖我', style: TextStyle(color: Colors.white))),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Text(_dragState, style: const TextStyle(fontSize: 12)),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () => setState(() => _dragOffset = Offset.zero),
                      child: const Text('重置'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ====== Scale 手势 ======
          _SectionTitle('Scale 手势识别器'),
          const _ExplainText(
            'onScaleStart / onScaleUpdate / onScaleEnd\n'
            '单指拖拽时 scale=1.0，双指可缩放和旋转。\n'
            '⚠️ 不能和 Pan 同时使用！',
          ),
          GestureDetector(
            onScaleStart: (d) {},
            onScaleUpdate: (d) => setState(() {
              _scale = d.scale.clamp(0.5, 3.0);
              _rotation = d.rotation;
            }),
            onScaleEnd: (d) {},
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                border: Border.all(color: Colors.purple),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: _rotation,
                  child: Transform.scale(
                    scale: _scale,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('缩放\n旋转', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'scale=${_scale.toStringAsFixed(2)}  rotation=${(_rotation * 180 / 3.14159).toStringAsFixed(1)}°',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 24),

          // ====== LongPress 手势 ======
          _SectionTitle('LongPress 手势识别器'),
          const _ExplainText(
            'onLongPress / onLongPressStart / onLongPressMoveUpdate / onLongPressEnd\n'
            '默认 500ms 触发，可通过 duration 自定义。',
          ),
          GestureDetector(
            onLongPress: () => setState(() => _longPressResult = '✅ onLongPress 长按触发'),
            onLongPressStart: (d) => setState(() => _longPressResult = '⬇️ 长按开始 ${d.localPosition}'),
            onLongPressMoveUpdate: (d) => setState(() => _longPressResult = '↔️ 长按移动 ${d.localPosition}'),
            onLongPressEnd: (d) => setState(() => _longPressResult = '⬆️ 长按结束'),
            child: Container(
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_longPressResult, style: const TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 24),

          // ====== RawGestureDetector ======
          _SectionTitle('RawGestureDetector — 手动管理识别器'),
          const _ExplainText(
            'RawGestureDetector 接收 GestureRecognizerFactory 映射，\n'
            '可以精确控制使用哪种识别器，是 GestureDetector 的底层 API。\n'
            '下面用它指定使用 TapGestureRecognizer，和 GestureDetector 效果相同：',
          ),
          RawGestureDetector(
            gestures: <Type, GestureRecognizerFactory>{
              TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                () => TapGestureRecognizer(),
                (TapGestureRecognizer instance) {
                  instance.onTap = () => setState(() => _rawResult = '✅ RawGestureDetector: 单击');
                  // 注意：双击需要配合 DoubleTapGestureRecognizer，此处仅演示单击
                },
              ),
            },
            child: Container(
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_rawResult, style: const TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ExplainText extends StatelessWidget {
  final String text;
  const _ExplainText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.5),
      ),
    );
  }
}

