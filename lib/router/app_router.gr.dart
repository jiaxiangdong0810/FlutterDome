// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i87;
import 'package:flutter/material.dart' as _i88;
import 'package:untitled1/main.dart' as _i46;
import 'package:untitled1/pages/event_mechanism/event_hub.dart' as _i20;
import 'package:untitled1/pages/event_mechanism/stage1_pointer_and_gesture/01_pointer_events.dart'
    as _i52;
import 'package:untitled1/pages/event_mechanism/stage1_pointer_and_gesture/02_gesture_recognizers.dart'
    as _i32;
import 'package:untitled1/pages/event_mechanism/stage1_pointer_and_gesture/03_gesture_arena.dart'
    as _i31;
import 'package:untitled1/pages/event_mechanism/stage2_event_dispatch/04_hit_testing.dart'
    as _i34;
import 'package:untitled1/pages/event_mechanism/stage2_event_dispatch/05_event_dispatch.dart'
    as _i19;
import 'package:untitled1/pages/event_mechanism/stage3_widget_events/06_notification.dart'
    as _i49;
import 'package:untitled1/pages/event_mechanism/stage3_widget_events/07_inherited_widget.dart'
    as _i39;
import 'package:untitled1/pages/event_mechanism/stage3_widget_events/08_focus_keyboard.dart'
    as _i26;
import 'package:untitled1/pages/event_mechanism/stage3_widget_events/09_event_debugging.dart'
    as _i18;
import 'package:untitled1/pages/test_async/async_hub.dart' as _i4;
import 'package:untitled1/pages/test_async/stage1_event_loop/01_event_loop_basics.dart'
    as _i21;
import 'package:untitled1/pages/test_async/stage1_event_loop/02_microtask_queue.dart'
    as _i44;
import 'package:untitled1/pages/test_async/stage1_event_loop/03_execution_order.dart'
    as _i22;
import 'package:untitled1/pages/test_async/stage2_future/01_future_basics.dart'
    as _i27;
import 'package:untitled1/pages/test_async/stage2_future/02_async_await.dart'
    as _i2;
import 'package:untitled1/pages/test_async/stage2_future/03_future_chain.dart'
    as _i28;
import 'package:untitled1/pages/test_async/stage2_future/04_future_combinators.dart'
    as _i29;
import 'package:untitled1/pages/test_async/stage2_future/05_error_handling.dart'
    as _i30;
import 'package:untitled1/pages/test_async/stage3_stream/01_stream_basics.dart'
    as _i72;
import 'package:untitled1/pages/test_async/stage3_stream/02_stream_types.dart'
    as _i77;
import 'package:untitled1/pages/test_async/stage3_stream/03_stream_controller.dart'
    as _i73;
import 'package:untitled1/pages/test_async/stage3_stream/04_stream_operators.dart'
    as _i75;
import 'package:untitled1/pages/test_async/stage4_stream_advanced/01_async_generator.dart'
    as _i3;
import 'package:untitled1/pages/test_async/stage4_stream_advanced/02_stream_transformer.dart'
    as _i76;
import 'package:untitled1/pages/test_async/stage4_stream_advanced/03_stream_merge_split.dart'
    as _i74;
import 'package:untitled1/pages/test_async/stage4_stream_advanced/04_backpressure.dart'
    as _i9;
import 'package:untitled1/pages/test_auto_route/auto_route_home_page.dart'
    as _i7;
import 'package:untitled1/pages/test_auto_route/auto_route_shell_page.dart'
    as _i8;
import 'package:untitled1/pages/test_auto_route/no_param_page.dart' as _i48;
import 'package:untitled1/pages/test_auto_route/return_value_page.dart' as _i62;
import 'package:untitled1/pages/test_auto_route/with_callback_page.dart'
    as _i85;
import 'package:untitled1/pages/test_auto_route/with_param_page.dart' as _i86;
import 'package:untitled1/pages/test_bloc/bloc_basics/main.dart' as _i10;
import 'package:untitled1/pages/test_bloc/bloc_list/main.dart' as _i11;
import 'package:untitled1/pages/test_bloc/bloc_list/post_detail_page.dart'
    as _i53;
import 'package:untitled1/pages/test_bloc/bloc_list/post_list_bloc.dart'
    as _i89;
import 'package:untitled1/pages/test_build/rebuild_demo_page.dart' as _i59;
import 'package:untitled1/pages/test_flavors/main.dart' as _i25;
import 'package:untitled1/pages/test_go_router/user_detail_page.dart' as _i81;
import 'package:untitled1/pages/test_go_router/user_list_page.dart' as _i82;
import 'package:untitled1/pages/test_https/01_http_basic.dart' as _i35;
import 'package:untitled1/pages/test_https/02_http_package_demo.dart' as _i36;
import 'package:untitled1/pages/test_https/03_dio_basic_demo.dart' as _i15;
import 'package:untitled1/pages/test_https/04_dio_interceptor_demo.dart'
    as _i17;
import 'package:untitled1/pages/test_https/05_dio_advanced_config.dart' as _i14;
import 'package:untitled1/pages/test_https/06_file_upload_download_demo.dart'
    as _i24;
import 'package:untitled1/pages/test_https/07_dio_client_demo.dart' as _i16;
import 'package:untitled1/pages/test_https/08_cache_strategy_demo.dart' as _i12;
import 'package:untitled1/pages/test_https/09_network_state_demo.dart' as _i47;
import 'package:untitled1/pages/test_https/10_auth_security_demo.dart' as _i6;
import 'package:untitled1/pages/test_https/11_websocket_demo.dart' as _i83;
import 'package:untitled1/pages/test_https/12_graphql_demo.dart' as _i33;
import 'package:untitled1/pages/test_https/clean_architecture/arch_demo_page.dart'
    as _i1;
import 'package:untitled1/pages/test_https/http_hub.dart' as _i78;
import 'package:untitled1/pages/test_https/http_testing/test_demo_page.dart'
    as _i37;
import 'package:untitled1/pages/test_https/perf_optimization/chunked_upload_demo.dart'
    as _i13;
import 'package:untitled1/pages/test_https/perf_optimization/isolate_parse_demo.dart'
    as _i42;
import 'package:untitled1/pages/test_https/perf_optimization/pagination_demo.dart'
    as _i50;
import 'package:untitled1/pages/test_https/perf_optimization/perf_hub.dart'
    as _i51;
import 'package:untitled1/pages/test_https/perf_optimization/request_debounce.dart'
    as _i61;
import 'package:untitled1/pages/test_integration/main.dart' as _i41;
import 'package:untitled1/pages/test_l10n/main.dart' as _i43;
import 'package:untitled1/pages/test_provider/02_basic/main.dart' as _i55;
import 'package:untitled1/pages/test_provider/03_multi/main.dart' as _i57;
import 'package:untitled1/pages/test_provider/04_async/main.dart' as _i54;
import 'package:untitled1/pages/test_provider/05_optimization/main.dart'
    as _i58;
import 'package:untitled1/pages/test_provider/06_cart/main.dart' as _i56;
import 'package:untitled1/pages/test_riverpod/01_hello_riverpod/main.dart'
    as _i66;
import 'package:untitled1/pages/test_riverpod/02_providers/main.dart' as _i69;
import 'package:untitled1/pages/test_riverpod/03_state_notifier/main.dart'
    as _i71;
import 'package:untitled1/pages/test_riverpod/04_consumer/main.dart' as _i64;
import 'package:untitled1/pages/test_riverpod/05_family/main.dart' as _i23;
import 'package:untitled1/pages/test_riverpod/06_auto_dispose/main.dart'
    as _i63;
import 'package:untitled1/pages/test_riverpod/07_dependency/main.dart' as _i65;
import 'package:untitled1/pages/test_riverpod/08_optimization/main.dart'
    as _i68;
import 'package:untitled1/pages/test_riverpod/09_async_value/main.dart' as _i5;
import 'package:untitled1/pages/test_riverpod/10_scoped_provider/main.dart'
    as _i70;
import 'package:untitled1/pages/test_riverpod/11_refresh/main.dart' as _i60;
import 'package:untitled1/pages/test_riverpod/12_todo/main.dart' as _i80;
import 'package:untitled1/pages/test_riverpod/hub.dart' as _i67;
import 'package:untitled1/pages/test_state/test_inherited_widget/main.dart'
    as _i38;
import 'package:untitled1/pages/test_state/test_inherited_widget_notifier/main.dart'
    as _i40;
import 'package:untitled1/pages/test_state/test_multi_listener/main.dart'
    as _i45;
import 'package:untitled1/pages/test_theme/main.dart' as _i79;
import 'package:untitled1/pages/test_widget/main.dart' as _i84;

/// generated route for
/// [_i1.ArchDemoPage]
class ArchDemoRoute extends _i87.PageRouteInfo<void> {
  const ArchDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(ArchDemoRoute.name, initialChildren: children);

  static const String name = 'ArchDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i1.ArchDemoPage();
    },
  );
}

/// generated route for
/// [_i2.AsyncAwaitPage]
class AsyncAwaitRoute extends _i87.PageRouteInfo<void> {
  const AsyncAwaitRoute({List<_i87.PageRouteInfo>? children})
    : super(AsyncAwaitRoute.name, initialChildren: children);

  static const String name = 'AsyncAwaitRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i2.AsyncAwaitPage();
    },
  );
}

/// generated route for
/// [_i3.AsyncGeneratorPage]
class AsyncGeneratorRoute extends _i87.PageRouteInfo<void> {
  const AsyncGeneratorRoute({List<_i87.PageRouteInfo>? children})
    : super(AsyncGeneratorRoute.name, initialChildren: children);

  static const String name = 'AsyncGeneratorRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i3.AsyncGeneratorPage();
    },
  );
}

/// generated route for
/// [_i4.AsyncHubPage]
class AsyncHubRoute extends _i87.PageRouteInfo<void> {
  const AsyncHubRoute({List<_i87.PageRouteInfo>? children})
    : super(AsyncHubRoute.name, initialChildren: children);

  static const String name = 'AsyncHubRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i4.AsyncHubPage();
    },
  );
}

/// generated route for
/// [_i5.AsyncValuePage]
class AsyncValueRoute extends _i87.PageRouteInfo<void> {
  const AsyncValueRoute({List<_i87.PageRouteInfo>? children})
    : super(AsyncValueRoute.name, initialChildren: children);

  static const String name = 'AsyncValueRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i5.AsyncValuePage();
    },
  );
}

/// generated route for
/// [_i6.AuthSecurityDemoPage]
class AuthSecurityDemoRoute extends _i87.PageRouteInfo<void> {
  const AuthSecurityDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(AuthSecurityDemoRoute.name, initialChildren: children);

  static const String name = 'AuthSecurityDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i6.AuthSecurityDemoPage();
    },
  );
}

/// generated route for
/// [_i7.AutoRouteHomePage]
class AutoRouteHomeRoute extends _i87.PageRouteInfo<void> {
  const AutoRouteHomeRoute({List<_i87.PageRouteInfo>? children})
    : super(AutoRouteHomeRoute.name, initialChildren: children);

  static const String name = 'AutoRouteHomeRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i7.AutoRouteHomePage();
    },
  );
}

/// generated route for
/// [_i8.AutoRouteShellPage]
class AutoRouteShellRoute extends _i87.PageRouteInfo<void> {
  const AutoRouteShellRoute({List<_i87.PageRouteInfo>? children})
    : super(AutoRouteShellRoute.name, initialChildren: children);

  static const String name = 'AutoRouteShellRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i8.AutoRouteShellPage();
    },
  );
}

/// generated route for
/// [_i9.BackpressurePage]
class BackpressureRoute extends _i87.PageRouteInfo<void> {
  const BackpressureRoute({List<_i87.PageRouteInfo>? children})
    : super(BackpressureRoute.name, initialChildren: children);

  static const String name = 'BackpressureRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i9.BackpressurePage();
    },
  );
}

/// generated route for
/// [_i10.BlocBasicsPage]
class BlocBasicsRoute extends _i87.PageRouteInfo<void> {
  const BlocBasicsRoute({List<_i87.PageRouteInfo>? children})
    : super(BlocBasicsRoute.name, initialChildren: children);

  static const String name = 'BlocBasicsRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i10.BlocBasicsPage();
    },
  );
}

/// generated route for
/// [_i11.BlocListPage]
class BlocListRoute extends _i87.PageRouteInfo<void> {
  const BlocListRoute({List<_i87.PageRouteInfo>? children})
    : super(BlocListRoute.name, initialChildren: children);

  static const String name = 'BlocListRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i11.BlocListPage();
    },
  );
}

/// generated route for
/// [_i12.CacheStrategyDemoPage]
class CacheStrategyDemoRoute extends _i87.PageRouteInfo<void> {
  const CacheStrategyDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(CacheStrategyDemoRoute.name, initialChildren: children);

  static const String name = 'CacheStrategyDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i12.CacheStrategyDemoPage();
    },
  );
}

/// generated route for
/// [_i13.ChunkedUploadDemoPage]
class ChunkedUploadDemoRoute extends _i87.PageRouteInfo<void> {
  const ChunkedUploadDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(ChunkedUploadDemoRoute.name, initialChildren: children);

  static const String name = 'ChunkedUploadDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i13.ChunkedUploadDemoPage();
    },
  );
}

/// generated route for
/// [_i14.DioAdvancedConfigPage]
class DioAdvancedConfigRoute extends _i87.PageRouteInfo<void> {
  const DioAdvancedConfigRoute({List<_i87.PageRouteInfo>? children})
    : super(DioAdvancedConfigRoute.name, initialChildren: children);

  static const String name = 'DioAdvancedConfigRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i14.DioAdvancedConfigPage();
    },
  );
}

/// generated route for
/// [_i15.DioBasicDemoPage]
class DioBasicDemoRoute extends _i87.PageRouteInfo<void> {
  const DioBasicDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(DioBasicDemoRoute.name, initialChildren: children);

  static const String name = 'DioBasicDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i15.DioBasicDemoPage();
    },
  );
}

/// generated route for
/// [_i16.DioClientDemoPage]
class DioClientDemoRoute extends _i87.PageRouteInfo<void> {
  const DioClientDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(DioClientDemoRoute.name, initialChildren: children);

  static const String name = 'DioClientDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i16.DioClientDemoPage();
    },
  );
}

/// generated route for
/// [_i17.DioInterceptorDemoPage]
class DioInterceptorDemoRoute extends _i87.PageRouteInfo<void> {
  const DioInterceptorDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(DioInterceptorDemoRoute.name, initialChildren: children);

  static const String name = 'DioInterceptorDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i17.DioInterceptorDemoPage();
    },
  );
}

/// generated route for
/// [_i18.EventDebuggingDemoPage]
class EventDebuggingDemoRoute extends _i87.PageRouteInfo<void> {
  const EventDebuggingDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(EventDebuggingDemoRoute.name, initialChildren: children);

  static const String name = 'EventDebuggingDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i18.EventDebuggingDemoPage();
    },
  );
}

/// generated route for
/// [_i19.EventDispatchPage]
class EventDispatchRoute extends _i87.PageRouteInfo<void> {
  const EventDispatchRoute({List<_i87.PageRouteInfo>? children})
    : super(EventDispatchRoute.name, initialChildren: children);

  static const String name = 'EventDispatchRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i19.EventDispatchPage();
    },
  );
}

/// generated route for
/// [_i20.EventHubPage]
class EventHubRoute extends _i87.PageRouteInfo<void> {
  const EventHubRoute({List<_i87.PageRouteInfo>? children})
    : super(EventHubRoute.name, initialChildren: children);

  static const String name = 'EventHubRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i20.EventHubPage();
    },
  );
}

/// generated route for
/// [_i21.EventLoopBasicsPage]
class EventLoopBasicsRoute extends _i87.PageRouteInfo<void> {
  const EventLoopBasicsRoute({List<_i87.PageRouteInfo>? children})
    : super(EventLoopBasicsRoute.name, initialChildren: children);

  static const String name = 'EventLoopBasicsRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i21.EventLoopBasicsPage();
    },
  );
}

/// generated route for
/// [_i22.ExecutionOrderPage]
class ExecutionOrderRoute extends _i87.PageRouteInfo<void> {
  const ExecutionOrderRoute({List<_i87.PageRouteInfo>? children})
    : super(ExecutionOrderRoute.name, initialChildren: children);

  static const String name = 'ExecutionOrderRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i22.ExecutionOrderPage();
    },
  );
}

/// generated route for
/// [_i23.FamilyDemoPage]
class FamilyDemoRoute extends _i87.PageRouteInfo<void> {
  const FamilyDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(FamilyDemoRoute.name, initialChildren: children);

  static const String name = 'FamilyDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i23.FamilyDemoPage();
    },
  );
}

/// generated route for
/// [_i24.FileUploadDownloadDemoPage]
class FileUploadDownloadDemoRoute extends _i87.PageRouteInfo<void> {
  const FileUploadDownloadDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(FileUploadDownloadDemoRoute.name, initialChildren: children);

  static const String name = 'FileUploadDownloadDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i24.FileUploadDownloadDemoPage();
    },
  );
}

/// generated route for
/// [_i25.FlavorsDemoPage]
class FlavorsDemoRoute extends _i87.PageRouteInfo<void> {
  const FlavorsDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(FlavorsDemoRoute.name, initialChildren: children);

  static const String name = 'FlavorsDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i25.FlavorsDemoPage();
    },
  );
}

/// generated route for
/// [_i26.FocusKeyboardDemoPage]
class FocusKeyboardDemoRoute extends _i87.PageRouteInfo<void> {
  const FocusKeyboardDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(FocusKeyboardDemoRoute.name, initialChildren: children);

  static const String name = 'FocusKeyboardDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i26.FocusKeyboardDemoPage();
    },
  );
}

/// generated route for
/// [_i27.FutureBasicsPage]
class FutureBasicsRoute extends _i87.PageRouteInfo<void> {
  const FutureBasicsRoute({List<_i87.PageRouteInfo>? children})
    : super(FutureBasicsRoute.name, initialChildren: children);

  static const String name = 'FutureBasicsRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i27.FutureBasicsPage();
    },
  );
}

/// generated route for
/// [_i28.FutureChainPage]
class FutureChainRoute extends _i87.PageRouteInfo<void> {
  const FutureChainRoute({List<_i87.PageRouteInfo>? children})
    : super(FutureChainRoute.name, initialChildren: children);

  static const String name = 'FutureChainRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i28.FutureChainPage();
    },
  );
}

/// generated route for
/// [_i29.FutureCombinatorsPage]
class FutureCombinatorsRoute extends _i87.PageRouteInfo<void> {
  const FutureCombinatorsRoute({List<_i87.PageRouteInfo>? children})
    : super(FutureCombinatorsRoute.name, initialChildren: children);

  static const String name = 'FutureCombinatorsRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i29.FutureCombinatorsPage();
    },
  );
}

/// generated route for
/// [_i30.FutureErrorHandlingPage]
class FutureErrorHandlingRoute extends _i87.PageRouteInfo<void> {
  const FutureErrorHandlingRoute({List<_i87.PageRouteInfo>? children})
    : super(FutureErrorHandlingRoute.name, initialChildren: children);

  static const String name = 'FutureErrorHandlingRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i30.FutureErrorHandlingPage();
    },
  );
}

/// generated route for
/// [_i31.GestureArenaPage]
class GestureArenaRoute extends _i87.PageRouteInfo<void> {
  const GestureArenaRoute({List<_i87.PageRouteInfo>? children})
    : super(GestureArenaRoute.name, initialChildren: children);

  static const String name = 'GestureArenaRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i31.GestureArenaPage();
    },
  );
}

/// generated route for
/// [_i32.GestureRecognizersPage]
class GestureRecognizersRoute extends _i87.PageRouteInfo<void> {
  const GestureRecognizersRoute({List<_i87.PageRouteInfo>? children})
    : super(GestureRecognizersRoute.name, initialChildren: children);

  static const String name = 'GestureRecognizersRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i32.GestureRecognizersPage();
    },
  );
}

/// generated route for
/// [_i33.GraphQLDemoPage]
class GraphQLDemoRoute extends _i87.PageRouteInfo<void> {
  const GraphQLDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(GraphQLDemoRoute.name, initialChildren: children);

  static const String name = 'GraphQLDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i33.GraphQLDemoPage();
    },
  );
}

/// generated route for
/// [_i34.HitTestingPage]
class HitTestingRoute extends _i87.PageRouteInfo<void> {
  const HitTestingRoute({List<_i87.PageRouteInfo>? children})
    : super(HitTestingRoute.name, initialChildren: children);

  static const String name = 'HitTestingRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i34.HitTestingPage();
    },
  );
}

/// generated route for
/// [_i35.HttpBasicPage]
class HttpBasicRoute extends _i87.PageRouteInfo<void> {
  const HttpBasicRoute({List<_i87.PageRouteInfo>? children})
    : super(HttpBasicRoute.name, initialChildren: children);

  static const String name = 'HttpBasicRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i35.HttpBasicPage();
    },
  );
}

/// generated route for
/// [_i36.HttpPackageDemoPage]
class HttpPackageDemoRoute extends _i87.PageRouteInfo<void> {
  const HttpPackageDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(HttpPackageDemoRoute.name, initialChildren: children);

  static const String name = 'HttpPackageDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i36.HttpPackageDemoPage();
    },
  );
}

/// generated route for
/// [_i37.HttpTestDemoPage]
class HttpTestDemoRoute extends _i87.PageRouteInfo<void> {
  const HttpTestDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(HttpTestDemoRoute.name, initialChildren: children);

  static const String name = 'HttpTestDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i37.HttpTestDemoPage();
    },
  );
}

/// generated route for
/// [_i38.InheritedWidgetDemoPage]
class InheritedWidgetDemoRoute extends _i87.PageRouteInfo<void> {
  const InheritedWidgetDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(InheritedWidgetDemoRoute.name, initialChildren: children);

  static const String name = 'InheritedWidgetDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i38.InheritedWidgetDemoPage();
    },
  );
}

/// generated route for
/// [_i39.InheritedWidgetEventDemoPage]
class InheritedWidgetEventDemoRoute extends _i87.PageRouteInfo<void> {
  const InheritedWidgetEventDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(InheritedWidgetEventDemoRoute.name, initialChildren: children);

  static const String name = 'InheritedWidgetEventDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i39.InheritedWidgetEventDemoPage();
    },
  );
}

/// generated route for
/// [_i40.InheritedWidgetNotifierPage]
class InheritedWidgetNotifierRoute extends _i87.PageRouteInfo<void> {
  const InheritedWidgetNotifierRoute({List<_i87.PageRouteInfo>? children})
    : super(InheritedWidgetNotifierRoute.name, initialChildren: children);

  static const String name = 'InheritedWidgetNotifierRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i40.InheritedWidgetNotifierPage();
    },
  );
}

/// generated route for
/// [_i41.IntegrationTestDemoPage]
class IntegrationTestDemoRoute extends _i87.PageRouteInfo<void> {
  const IntegrationTestDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(IntegrationTestDemoRoute.name, initialChildren: children);

  static const String name = 'IntegrationTestDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i41.IntegrationTestDemoPage();
    },
  );
}

/// generated route for
/// [_i42.IsolateParseDemoPage]
class IsolateParseDemoRoute extends _i87.PageRouteInfo<void> {
  const IsolateParseDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(IsolateParseDemoRoute.name, initialChildren: children);

  static const String name = 'IsolateParseDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i42.IsolateParseDemoPage();
    },
  );
}

/// generated route for
/// [_i43.L10nDemoPage]
class L10nDemoRoute extends _i87.PageRouteInfo<void> {
  const L10nDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(L10nDemoRoute.name, initialChildren: children);

  static const String name = 'L10nDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i43.L10nDemoPage();
    },
  );
}

/// generated route for
/// [_i44.MicrotaskQueuePage]
class MicrotaskQueueRoute extends _i87.PageRouteInfo<void> {
  const MicrotaskQueueRoute({List<_i87.PageRouteInfo>? children})
    : super(MicrotaskQueueRoute.name, initialChildren: children);

  static const String name = 'MicrotaskQueueRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i44.MicrotaskQueuePage();
    },
  );
}

/// generated route for
/// [_i45.MultiListenerPage]
class MultiListenerRoute extends _i87.PageRouteInfo<void> {
  const MultiListenerRoute({List<_i87.PageRouteInfo>? children})
    : super(MultiListenerRoute.name, initialChildren: children);

  static const String name = 'MultiListenerRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i45.MultiListenerPage();
    },
  );
}

/// generated route for
/// [_i46.MyHomePage]
class MyHomeRoute extends _i87.PageRouteInfo<void> {
  const MyHomeRoute({List<_i87.PageRouteInfo>? children})
    : super(MyHomeRoute.name, initialChildren: children);

  static const String name = 'MyHomeRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i46.MyHomePage();
    },
  );
}

/// generated route for
/// [_i47.NetworkStateDemoPage]
class NetworkStateDemoRoute extends _i87.PageRouteInfo<void> {
  const NetworkStateDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(NetworkStateDemoRoute.name, initialChildren: children);

  static const String name = 'NetworkStateDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i47.NetworkStateDemoPage();
    },
  );
}

/// generated route for
/// [_i48.NoParamPage]
class NoParamRoute extends _i87.PageRouteInfo<void> {
  const NoParamRoute({List<_i87.PageRouteInfo>? children})
    : super(NoParamRoute.name, initialChildren: children);

  static const String name = 'NoParamRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i48.NoParamPage();
    },
  );
}

/// generated route for
/// [_i49.NotificationDemoPage]
class NotificationDemoRoute extends _i87.PageRouteInfo<void> {
  const NotificationDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(NotificationDemoRoute.name, initialChildren: children);

  static const String name = 'NotificationDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i49.NotificationDemoPage();
    },
  );
}

/// generated route for
/// [_i50.PaginationDemoPage]
class PaginationDemoRoute extends _i87.PageRouteInfo<void> {
  const PaginationDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(PaginationDemoRoute.name, initialChildren: children);

  static const String name = 'PaginationDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i50.PaginationDemoPage();
    },
  );
}

/// generated route for
/// [_i51.PerfOptimizationPage]
class PerfOptimizationRoute extends _i87.PageRouteInfo<void> {
  const PerfOptimizationRoute({List<_i87.PageRouteInfo>? children})
    : super(PerfOptimizationRoute.name, initialChildren: children);

  static const String name = 'PerfOptimizationRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i51.PerfOptimizationPage();
    },
  );
}

/// generated route for
/// [_i52.PointerEventsPage]
class PointerEventsRoute extends _i87.PageRouteInfo<void> {
  const PointerEventsRoute({List<_i87.PageRouteInfo>? children})
    : super(PointerEventsRoute.name, initialChildren: children);

  static const String name = 'PointerEventsRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i52.PointerEventsPage();
    },
  );
}

/// generated route for
/// [_i53.PostDetailPage]
class PostDetailRoute extends _i87.PageRouteInfo<PostDetailRouteArgs> {
  PostDetailRoute({
    _i88.Key? key,
    required _i89.Post post,
    List<_i87.PageRouteInfo>? children,
  }) : super(
         PostDetailRoute.name,
         args: PostDetailRouteArgs(key: key, post: post),
         initialChildren: children,
       );

  static const String name = 'PostDetailRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostDetailRouteArgs>();
      return _i53.PostDetailPage(key: args.key, post: args.post);
    },
  );
}

class PostDetailRouteArgs {
  const PostDetailRouteArgs({this.key, required this.post});

  final _i88.Key? key;

  final _i89.Post post;

  @override
  String toString() {
    return 'PostDetailRouteArgs{key: $key, post: $post}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDetailRouteArgs) return false;
    return key == other.key && post == other.post;
  }

  @override
  int get hashCode => key.hashCode ^ post.hashCode;
}

/// generated route for
/// [_i54.ProviderAsyncRoute]
class ProviderAsyncRoute extends _i87.PageRouteInfo<void> {
  const ProviderAsyncRoute({List<_i87.PageRouteInfo>? children})
    : super(ProviderAsyncRoute.name, initialChildren: children);

  static const String name = 'ProviderAsyncRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i54.ProviderAsyncRoute();
    },
  );
}

/// generated route for
/// [_i55.ProviderBasicRoute]
class ProviderBasicRoute extends _i87.PageRouteInfo<void> {
  const ProviderBasicRoute({List<_i87.PageRouteInfo>? children})
    : super(ProviderBasicRoute.name, initialChildren: children);

  static const String name = 'ProviderBasicRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i55.ProviderBasicRoute();
    },
  );
}

/// generated route for
/// [_i56.ProviderCartRoute]
class ProviderCartRoute extends _i87.PageRouteInfo<void> {
  const ProviderCartRoute({List<_i87.PageRouteInfo>? children})
    : super(ProviderCartRoute.name, initialChildren: children);

  static const String name = 'ProviderCartRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i56.ProviderCartRoute();
    },
  );
}

/// generated route for
/// [_i57.ProviderMultiRoute]
class ProviderMultiRoute extends _i87.PageRouteInfo<void> {
  const ProviderMultiRoute({List<_i87.PageRouteInfo>? children})
    : super(ProviderMultiRoute.name, initialChildren: children);

  static const String name = 'ProviderMultiRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i57.ProviderMultiRoute();
    },
  );
}

/// generated route for
/// [_i58.ProviderOptimizationRoute]
class ProviderOptimizationRoute extends _i87.PageRouteInfo<void> {
  const ProviderOptimizationRoute({List<_i87.PageRouteInfo>? children})
    : super(ProviderOptimizationRoute.name, initialChildren: children);

  static const String name = 'ProviderOptimizationRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i58.ProviderOptimizationRoute();
    },
  );
}

/// generated route for
/// [_i59.RebuildDemoPage]
class RebuildDemoRoute extends _i87.PageRouteInfo<void> {
  const RebuildDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(RebuildDemoRoute.name, initialChildren: children);

  static const String name = 'RebuildDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i59.RebuildDemoPage();
    },
  );
}

/// generated route for
/// [_i60.RefreshDemoPage]
class RefreshDemoRoute extends _i87.PageRouteInfo<void> {
  const RefreshDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(RefreshDemoRoute.name, initialChildren: children);

  static const String name = 'RefreshDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i60.RefreshDemoPage();
    },
  );
}

/// generated route for
/// [_i61.RequestDebouncePage]
class RequestDebounceRoute extends _i87.PageRouteInfo<void> {
  const RequestDebounceRoute({List<_i87.PageRouteInfo>? children})
    : super(RequestDebounceRoute.name, initialChildren: children);

  static const String name = 'RequestDebounceRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i61.RequestDebouncePage();
    },
  );
}

/// generated route for
/// [_i62.ReturnValuePage]
class ReturnValueRoute extends _i87.PageRouteInfo<void> {
  const ReturnValueRoute({List<_i87.PageRouteInfo>? children})
    : super(ReturnValueRoute.name, initialChildren: children);

  static const String name = 'ReturnValueRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i62.ReturnValuePage();
    },
  );
}

/// generated route for
/// [_i63.RiverpodAutoDisposePage]
class RiverpodAutoDisposeRoute extends _i87.PageRouteInfo<void> {
  const RiverpodAutoDisposeRoute({List<_i87.PageRouteInfo>? children})
    : super(RiverpodAutoDisposeRoute.name, initialChildren: children);

  static const String name = 'RiverpodAutoDisposeRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i63.RiverpodAutoDisposePage();
    },
  );
}

/// generated route for
/// [_i64.RiverpodConsumerPage]
class RiverpodConsumerRoute extends _i87.PageRouteInfo<void> {
  const RiverpodConsumerRoute({List<_i87.PageRouteInfo>? children})
    : super(RiverpodConsumerRoute.name, initialChildren: children);

  static const String name = 'RiverpodConsumerRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i64.RiverpodConsumerPage();
    },
  );
}

/// generated route for
/// [_i65.RiverpodDependencyPage]
class RiverpodDependencyRoute extends _i87.PageRouteInfo<void> {
  const RiverpodDependencyRoute({List<_i87.PageRouteInfo>? children})
    : super(RiverpodDependencyRoute.name, initialChildren: children);

  static const String name = 'RiverpodDependencyRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i65.RiverpodDependencyPage();
    },
  );
}

/// generated route for
/// [_i66.RiverpodHelloPage]
class RiverpodHelloRoute extends _i87.PageRouteInfo<void> {
  const RiverpodHelloRoute({List<_i87.PageRouteInfo>? children})
    : super(RiverpodHelloRoute.name, initialChildren: children);

  static const String name = 'RiverpodHelloRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i66.RiverpodHelloPage();
    },
  );
}

/// generated route for
/// [_i67.RiverpodHubPage]
class RiverpodHubRoute extends _i87.PageRouteInfo<void> {
  const RiverpodHubRoute({List<_i87.PageRouteInfo>? children})
    : super(RiverpodHubRoute.name, initialChildren: children);

  static const String name = 'RiverpodHubRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i67.RiverpodHubPage();
    },
  );
}

/// generated route for
/// [_i68.RiverpodOptimizationPage]
class RiverpodOptimizationRoute extends _i87.PageRouteInfo<void> {
  const RiverpodOptimizationRoute({List<_i87.PageRouteInfo>? children})
    : super(RiverpodOptimizationRoute.name, initialChildren: children);

  static const String name = 'RiverpodOptimizationRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i68.RiverpodOptimizationPage();
    },
  );
}

/// generated route for
/// [_i69.RiverpodProvidersPage]
class RiverpodProvidersRoute extends _i87.PageRouteInfo<void> {
  const RiverpodProvidersRoute({List<_i87.PageRouteInfo>? children})
    : super(RiverpodProvidersRoute.name, initialChildren: children);

  static const String name = 'RiverpodProvidersRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i69.RiverpodProvidersPage();
    },
  );
}

/// generated route for
/// [_i70.RiverpodScopedPage]
class RiverpodScopedRoute extends _i87.PageRouteInfo<void> {
  const RiverpodScopedRoute({List<_i87.PageRouteInfo>? children})
    : super(RiverpodScopedRoute.name, initialChildren: children);

  static const String name = 'RiverpodScopedRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i70.RiverpodScopedPage();
    },
  );
}

/// generated route for
/// [_i71.RiverpodStateNotifierPage]
class RiverpodStateNotifierRoute extends _i87.PageRouteInfo<void> {
  const RiverpodStateNotifierRoute({List<_i87.PageRouteInfo>? children})
    : super(RiverpodStateNotifierRoute.name, initialChildren: children);

  static const String name = 'RiverpodStateNotifierRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i71.RiverpodStateNotifierPage();
    },
  );
}

/// generated route for
/// [_i72.StreamBasicsPage]
class StreamBasicsRoute extends _i87.PageRouteInfo<void> {
  const StreamBasicsRoute({List<_i87.PageRouteInfo>? children})
    : super(StreamBasicsRoute.name, initialChildren: children);

  static const String name = 'StreamBasicsRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i72.StreamBasicsPage();
    },
  );
}

/// generated route for
/// [_i73.StreamControllerPage]
class StreamControllerRoute extends _i87.PageRouteInfo<void> {
  const StreamControllerRoute({List<_i87.PageRouteInfo>? children})
    : super(StreamControllerRoute.name, initialChildren: children);

  static const String name = 'StreamControllerRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i73.StreamControllerPage();
    },
  );
}

/// generated route for
/// [_i74.StreamMergeSplitPage]
class StreamMergeSplitRoute extends _i87.PageRouteInfo<void> {
  const StreamMergeSplitRoute({List<_i87.PageRouteInfo>? children})
    : super(StreamMergeSplitRoute.name, initialChildren: children);

  static const String name = 'StreamMergeSplitRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i74.StreamMergeSplitPage();
    },
  );
}

/// generated route for
/// [_i75.StreamOperatorsPage]
class StreamOperatorsRoute extends _i87.PageRouteInfo<void> {
  const StreamOperatorsRoute({List<_i87.PageRouteInfo>? children})
    : super(StreamOperatorsRoute.name, initialChildren: children);

  static const String name = 'StreamOperatorsRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i75.StreamOperatorsPage();
    },
  );
}

/// generated route for
/// [_i76.StreamTransformerPage]
class StreamTransformerRoute extends _i87.PageRouteInfo<void> {
  const StreamTransformerRoute({List<_i87.PageRouteInfo>? children})
    : super(StreamTransformerRoute.name, initialChildren: children);

  static const String name = 'StreamTransformerRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i76.StreamTransformerPage();
    },
  );
}

/// generated route for
/// [_i77.StreamTypesPage]
class StreamTypesRoute extends _i87.PageRouteInfo<void> {
  const StreamTypesRoute({List<_i87.PageRouteInfo>? children})
    : super(StreamTypesRoute.name, initialChildren: children);

  static const String name = 'StreamTypesRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i77.StreamTypesPage();
    },
  );
}

/// generated route for
/// [_i78.TestHttpsPage]
class TestHttpsRoute extends _i87.PageRouteInfo<void> {
  const TestHttpsRoute({List<_i87.PageRouteInfo>? children})
    : super(TestHttpsRoute.name, initialChildren: children);

  static const String name = 'TestHttpsRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i78.TestHttpsPage();
    },
  );
}

/// generated route for
/// [_i79.ThemeDemoPage]
class ThemeDemoRoute extends _i87.PageRouteInfo<void> {
  const ThemeDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(ThemeDemoRoute.name, initialChildren: children);

  static const String name = 'ThemeDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i79.ThemeDemoPage();
    },
  );
}

/// generated route for
/// [_i80.TodoPage]
class TodoRoute extends _i87.PageRouteInfo<void> {
  const TodoRoute({List<_i87.PageRouteInfo>? children})
    : super(TodoRoute.name, initialChildren: children);

  static const String name = 'TodoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i80.TodoPage();
    },
  );
}

/// generated route for
/// [_i81.UserDetailPage]
class UserDetailRoute extends _i87.PageRouteInfo<UserDetailRouteArgs> {
  UserDetailRoute({
    _i88.Key? key,
    required String userId,
    String? userName,
    List<_i87.PageRouteInfo>? children,
  }) : super(
         UserDetailRoute.name,
         args: UserDetailRouteArgs(
           key: key,
           userId: userId,
           userName: userName,
         ),
         rawPathParams: {'id': userId},
         rawQueryParams: {'userName': userName},
         initialChildren: children,
       );

  static const String name = 'UserDetailRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<UserDetailRouteArgs>(
        orElse: () => UserDetailRouteArgs(
          userId: pathParams.getString('id'),
          userName: queryParams.optString('userName'),
        ),
      );
      return _i81.UserDetailPage(
        key: args.key,
        userId: args.userId,
        userName: args.userName,
      );
    },
  );
}

class UserDetailRouteArgs {
  const UserDetailRouteArgs({this.key, required this.userId, this.userName});

  final _i88.Key? key;

  final String userId;

  final String? userName;

  @override
  String toString() {
    return 'UserDetailRouteArgs{key: $key, userId: $userId, userName: $userName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserDetailRouteArgs) return false;
    return key == other.key &&
        userId == other.userId &&
        userName == other.userName;
  }

  @override
  int get hashCode => key.hashCode ^ userId.hashCode ^ userName.hashCode;
}

/// generated route for
/// [_i82.UserListPage]
class UserListRoute extends _i87.PageRouteInfo<void> {
  const UserListRoute({List<_i87.PageRouteInfo>? children})
    : super(UserListRoute.name, initialChildren: children);

  static const String name = 'UserListRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i82.UserListPage();
    },
  );
}

/// generated route for
/// [_i83.WebSocketDemoPage]
class WebSocketDemoRoute extends _i87.PageRouteInfo<void> {
  const WebSocketDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(WebSocketDemoRoute.name, initialChildren: children);

  static const String name = 'WebSocketDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i83.WebSocketDemoPage();
    },
  );
}

/// generated route for
/// [_i84.WidgetTestDemoPage]
class WidgetTestDemoRoute extends _i87.PageRouteInfo<void> {
  const WidgetTestDemoRoute({List<_i87.PageRouteInfo>? children})
    : super(WidgetTestDemoRoute.name, initialChildren: children);

  static const String name = 'WidgetTestDemoRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      return const _i84.WidgetTestDemoPage();
    },
  );
}

/// generated route for
/// [_i85.WithCallbackPage]
class WithCallbackRoute extends _i87.PageRouteInfo<WithCallbackRouteArgs> {
  WithCallbackRoute({
    _i88.Key? key,
    required void Function(String) onConfirmed,
    List<_i87.PageRouteInfo>? children,
  }) : super(
         WithCallbackRoute.name,
         args: WithCallbackRouteArgs(key: key, onConfirmed: onConfirmed),
         initialChildren: children,
       );

  static const String name = 'WithCallbackRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WithCallbackRouteArgs>();
      return _i85.WithCallbackPage(
        key: args.key,
        onConfirmed: args.onConfirmed,
      );
    },
  );
}

class WithCallbackRouteArgs {
  const WithCallbackRouteArgs({this.key, required this.onConfirmed});

  final _i88.Key? key;

  final void Function(String) onConfirmed;

  @override
  String toString() {
    return 'WithCallbackRouteArgs{key: $key, onConfirmed: $onConfirmed}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WithCallbackRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i86.WithParamPage]
class WithParamRoute extends _i87.PageRouteInfo<WithParamRouteArgs> {
  WithParamRoute({
    _i88.Key? key,
    required String userId,
    String? userName,
    List<_i87.PageRouteInfo>? children,
  }) : super(
         WithParamRoute.name,
         args: WithParamRouteArgs(key: key, userId: userId, userName: userName),
         rawPathParams: {'id': userId},
         rawQueryParams: {'userName': userName},
         initialChildren: children,
       );

  static const String name = 'WithParamRoute';

  static _i87.PageInfo page = _i87.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<WithParamRouteArgs>(
        orElse: () => WithParamRouteArgs(
          userId: pathParams.getString('id'),
          userName: queryParams.optString('userName'),
        ),
      );
      return _i86.WithParamPage(
        key: args.key,
        userId: args.userId,
        userName: args.userName,
      );
    },
  );
}

class WithParamRouteArgs {
  const WithParamRouteArgs({this.key, required this.userId, this.userName});

  final _i88.Key? key;

  final String userId;

  final String? userName;

  @override
  String toString() {
    return 'WithParamRouteArgs{key: $key, userId: $userId, userName: $userName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WithParamRouteArgs) return false;
    return key == other.key &&
        userId == other.userId &&
        userName == other.userName;
  }

  @override
  int get hashCode => key.hashCode ^ userId.hashCode ^ userName.hashCode;
}
