import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: MyHomeRoute.page, path: '/'),
    AutoRoute(page: UserListRoute.page, path: '/users'),
    AutoRoute(page: UserDetailRoute.page, path: '/user/:id'),
    AutoRoute(page: RebuildDemoRoute.page, path: '/rebuild-demo'),
    AutoRoute(page: BlocBasicsRoute.page, path: '/bloc-basics'),
    AutoRoute(page: BlocListRoute.page, path: '/bloc-list'),
    AutoRoute(page: PostDetailRoute.page, path: '/post-detail'),
    AutoRoute(page: AutoRouteHomeRoute.page, path: '/auto-route'),
    AutoRoute(page: NoParamRoute.page, path: '/auto-route/no-param'),
    AutoRoute(page: WithParamRoute.page, path: '/auto-route/with-param/:id'),
    AutoRoute(page: ReturnValueRoute.page, path: '/auto-route/return-value'),
    AutoRoute(page: WithCallbackRoute.page, path: '/auto-route/with-callback'),
    AutoRoute(page: FlavorsDemoRoute.page, path: '/flavors'),
    AutoRoute(page: WidgetTestDemoRoute.page, path: '/widget-test'),
    AutoRoute(page: IntegrationTestDemoRoute.page, path: '/integration-test'),
    AutoRoute(page: ThemeDemoRoute.page, path: '/theme'),
    AutoRoute(page: L10nDemoRoute.page, path: '/l10n'),
    AutoRoute(page: InheritedWidgetDemoRoute.page, path: '/inherited-widget'),
    AutoRoute(page: InheritedWidgetNotifierRoute.page, path: '/inherited-widget-notifier'),
    AutoRoute(page: MultiListenerRoute.page, path: '/multi-listener'),
    AutoRoute(page: ProviderBasicRoute.page, path: '/provider-basic'),
    AutoRoute(page: ProviderMultiRoute.page, path: '/provider-multi'),
    AutoRoute(page: ProviderAsyncRoute.page, path: '/provider-async'),
    AutoRoute(page: ProviderOptimizationRoute.page, path: '/provider-optimization'),
    AutoRoute(page: ProviderCartRoute.page, path: '/provider-cart'),

    // Riverpod 学习路径
    AutoRoute(page: RiverpodHelloRoute.page, path: '/riverpod-hello'),
    AutoRoute(page: RiverpodProvidersRoute.page, path: '/riverpod-providers'),
    AutoRoute(page: RiverpodStateNotifierRoute.page, path: '/riverpod-state-notifier'),
    AutoRoute(page: RiverpodConsumerRoute.page, path: '/riverpod-consumer'),
    AutoRoute(page: FamilyDemoRoute.page, path: '/riverpod-family'),
    AutoRoute(page: RiverpodAutoDisposeRoute.page, path: '/riverpod-autodispose'),
    AutoRoute(page: RiverpodDependencyRoute.page, path: '/riverpod-dependency'),
    AutoRoute(page: RiverpodOptimizationRoute.page, path: '/riverpod-optimization'),
    AutoRoute(page: AsyncValueRoute.page, path: '/riverpod-async-value'),
    AutoRoute(page: RiverpodScopedRoute.page, path: '/riverpod-scoped-provider'),
    AutoRoute(page: RefreshDemoRoute.page, path: '/riverpod-refresh'),
    AutoRoute(page: TodoRoute.page, path: '/riverpod-todo'),

    // HTTP 学习路径
    AutoRoute(page: TestHttpsRoute.page, path: '/test-https'),
    AutoRoute(page: HttpBasicRoute.page, path: '/test-https/basic'),
    AutoRoute(page: HttpPackageDemoRoute.page, path: '/test-https/http-package'),
    AutoRoute(page: DioBasicDemoRoute.page, path: '/test-https/dio-basic'),
    AutoRoute(page: DioInterceptorDemoRoute.page, path: '/test-https/dio-interceptor'),
    AutoRoute(page: DioAdvancedConfigRoute.page, path: '/test-https/dio-advanced'),
    AutoRoute(page: FileUploadDownloadDemoRoute.page, path: '/test-https/file-upload-download'),
    AutoRoute(page: DioClientDemoRoute.page, path: '/test-https/dio-client'),
    AutoRoute(page: CacheStrategyDemoRoute.page, path: '/test-https/cache-strategy'),
    AutoRoute(page: NetworkStateDemoRoute.page, path: '/test-https/network-state'),
  ];
}
