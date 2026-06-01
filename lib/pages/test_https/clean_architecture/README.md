# Clean Architecture 架构模式

本目录演示大型项目的网络层架构：

## 目录结构
```
clean_architecture/
├── data/                    # 数据层
│   ├── api/                 # API 客户端
│   │   └── api_client.dart  # Dio 封装
│   ├── models/              # 数据模型（DTO）
│   │   └── user_dto.dart    # API 数据传输对象
│   └── repositories/        # 仓库实现
│       └── user_repository_impl.dart
├── domain/                  # 领域层
│   ├── entities/            # 业务实体
│   │   └── user.dart
│   └── repositories/        # 仓库接口（抽象）
│       └── user_repository.dart
└── arch_demo_page.dart      # 演示页面
```

## 核心原则
- **依赖倒置**：领域层定义接口，数据层实现
- **单一职责**：每层只负责自己的逻辑
- **可测试性**：通过接口注入 Mock
