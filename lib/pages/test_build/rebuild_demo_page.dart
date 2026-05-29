import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:untitled1/utils/log.dart';

@RoutePage()
class RebuildDemoPage extends StatelessWidget {
  const RebuildDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    LogByCommon.d('【父组件】RebuildDemoPage build');
    return Scaffold(
      appBar: AppBar(title: const Text('Widget 重建机制演示')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('父组件 setState', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('点击按钮让父组件 setState，观察两个子组件是否重建'),
              SizedBox(height: 12),
              ParentWithChildren(),
            ],
          ),
        ),
    );
  }
}

class ParentWithChildren extends StatefulWidget {
  const ParentWithChildren({super.key});

  @override
  State<ParentWithChildren> createState() => _ParentWithChildrenState();
}

class _ParentWithChildrenState extends State<ParentWithChildren> {
  int _parentCount = 0;


  @override
  Widget build(BuildContext context) {
    LogByCommon.d('【父组件】ParentWithChildren build，count = $_parentCount');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('父组件计数: $_parentCount'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _parentCount++),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('父组件 +1（setState）', style: TextStyle(color: Colors.white)),
              ),
            ),
            const Divider(height: 24),

            // 非 const 子组件：每次父组件 setState 都会重建
            // PaintLogger(name: 'NonConstChild', child: NonConstChild(value: _parentCount)),

            const SizedBox(height: 12),

            // const 子组件：父组件 setState 不会触发它重建
             PaintLogger(name: 'ConstChild', child:  ConstChild()),
            // const SizedBox(height: 12),
            // RawBWidget()
          ],
        ),
      ),
    );
  }
}

class NonConstChild extends StatelessWidget {
  final int value;

  const NonConstChild({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    LogByCommon.d('【非const子组件】build 被调用了，value = $value');
    return
      _LayoutDetectorRenderWidget(
          label: "11",
          child:Container(
      padding: const EdgeInsets.all(8),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text('非 const 子组件（接收参数 value=$value）→ 父 setState 时会重建'),
          ),
        ],
      ),),
    );

  }
}

class PaintLogger extends SingleChildRenderObjectWidget {
  final String name;
  const PaintLogger({super.key, required this.name, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderPaintLogger(name: name);
}

class _RenderPaintLogger extends RenderProxyBox {
  final String name;
  static final Map<String, int> _callCounts = {};
  static int? _lastFrame;

  _RenderPaintLogger({required this.name});

  @override
  void paint(PaintingContext context, Offset offset) {
    final count = (_callCounts[name] ?? 0) + 1;
    _callCounts[name] = count;
    final frame = DateTime.now().millisecondsSinceEpoch;
    final sameFrame = _lastFrame != null && frame - _lastFrame! < 20;
    _lastFrame = frame;
    LogByCommon.d('【Paint】$name 第 $count 次${sameFrame ? "【同帧】" : ""}');
    super.paint(context, offset);
  }
}



class ConstChild extends StatelessWidget {
  const ConstChild({super.key});
  @override
  Widget build(BuildContext context) {
    LogByCommon.d('【const子组件】build 被调用了');
    return
      _LayoutDetectorRenderWidget(
        label: "11",
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.green.shade100,
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text('const 子组件（无参数）→ 父 setState 时不会重建'),
              ),
            ],
          ),
        ),
      )
    ;
  }
}
// ====== 用底层 RenderObject 组装的 纯原始 BWidget ======
class RawBWidget extends LeafRenderObjectWidget {
  const RawBWidget({super.key});

  @override
  RenderObject createRenderObject(BuildContext context) => RenderRawB();
}

class RenderRawB extends RenderBox {
  @override
  void performLayout() {
    LogByCommon.d("🚨 【底层警报】RenderRawB 的 performLayout 绘制方法真正执行了！！！");
    size = const Size(100, 100); // 固定大小
  }

  // 🔥 重点：这是 Flutter 真正的重绘发生地！
  // 如果这里被执行了，说明显卡真正重新计算了 B 的像素！
  @override
  void paint(PaintingContext context, Offset offset) {
    LogByCommon.d("🚨 【底层警报】RenderRawB 的 paint 绘制方法真正执行了！！！");
    final Paint paint = Paint()..color = Colors.blue;
    context.canvas.drawRect(offset & size, paint);
  }
}


// 内部辅助组件：用于挂载底层 RenderObject
class _LayoutDetectorRenderWidget extends SingleChildRenderObjectWidget {
  final String label;

  const _LayoutDetectorRenderWidget({required this.label, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderDetector(label);

  @override
  void updateRenderObject(BuildContext context, covariant _RenderDetector renderObject) {
    renderObject.label = label;
  }
}

// 内部辅助底层对象：用于拦截 Layout
class _RenderDetector extends RenderProxyBox {
  String label;
  _RenderDetector(this.label);

  @override
  void performLayout() {
    // 2. 拦截并打印 Layout
    LogByCommon.d("📐 【Layout】===> $label 执行了 performLayout 布局计算");
    super.performLayout(); // 保持原有的布局逻辑
  }
}

// ❌ 错误：Widget 必须是 immutable
class BadWidget extends StatelessWidget {
  const BadWidget({super.key});
  final String text = '初始值'; // 运行时不会报错，但违背设计契约

  @override
  Widget build(BuildContext context) => Text(text);
}

