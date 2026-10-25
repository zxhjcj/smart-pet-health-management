# 智能宠物健康管理系统

基于 C#、ASP.NET Web Forms 和 SQL Server 的宠物健康管理课程项目，集中管理宠物档案、健康记录与日常养护提醒。

## 主要功能

- 用户注册、登录与退出，基于 Session 的普通用户和管理员权限控制。
- 宠物档案管理与详情查看。
- 记录体重、体温、饮食、运动及症状等健康信息。
- 疫苗、驱虫、体检站内提醒及已读状态管理。
- 基于关键词规则的健康咨询和咨询记录保存，当前未接入大模型 API。
- 后台用户管理与系统公告管理。

## 技术栈

- C# / ASP.NET Web Forms / .NET Framework 4.7.2
- SQL Server / SQL Server LocalDB
- ADO.NET，使用参数化 SQL 访问数据库
- HTML / CSS，使用 Master Page 统一页面布局

## 本地运行

1. 在 Windows 上安装 Visual Studio 的“ASP.NET 和 Web 开发”工作负载、.NET Framework 4.7.2 开发工具以及 SQL Server LocalDB（或 SQL Server）。
2. 使用 SQL Server Management Studio 等工具执行 `Database/SmartPetHealthDb.sql`，创建数据库和表。
3. 检查 `Web.config` 中名为 `SmartPetHealthDb` 的连接字符串。默认连接本机 `(localdb)\MSSQLLocalDB`，数据库为 `SmartPetHealthDb`，采用 Windows 集成身份验证。
4. 在 Visual Studio 中使用“打开网站”打开仓库根目录。仓库中的 `.slnx` 包含原作者的本机路径，跨电脑使用时建议直接打开网站目录。
5. 根据 `packages.config` 还原 NuGet 依赖 `Microsoft.CodeDom.Providers.DotNetCompilerPlatform` 2.0.1，确认网站 `Bin` 中包含所需程序集和编译器文件，再通过 IIS Express 启动 `Default.aspx`。本仓库不包含 `packages`、`Bin` 或预编译输出。

数据库初始化脚本包含用于本地演示的管理员账号：`admin` / `admin123`。请仅用于本地演示，实际部署前更改默认凭据。

## 项目结构

```text
App_Code/       数据访问、身份认证与规则问答
Content/        页面样式
Database/       数据库初始化脚本与表结构说明
*.aspx          首页、登录注册、宠物、健康、提醒、咨询及后台页面
Site.master     公共页面布局
Web.config      网站及数据库连接配置
packages.config NuGet 依赖清单
```

健康咨询结果仅供养护参考，不能替代兽医诊断。
