# 性能优化专题

本目录包含 Flutter 网络请求性能优化的核心演示：

- **request_debounce.dart** - 请求防抖：避免频繁触发网络请求（搜索框等场景）
- **pagination_demo.dart** - 分页加载：滚动加载更多 + 下拉刷新
- **chunked_upload_demo.dart** - 分块上传：大文件分片上传 + 断点续传
- **isolate_parse_demo.dart** - Isolate 解析：在后台线程解析大型 JSON
