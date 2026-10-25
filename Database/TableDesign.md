# 智能宠物健康管理系统库表设计

数据库采用 SQL Server，核心业务围绕用户、宠物档案、健康记录、疫苗驱虫提醒、AI 健康咨询和后台公告展开。

## 1. Users 用户信息表

| 字段名 | 类型 | 约束 | 含义 |
|---|---|---|---|
| UserId | INT | 主键，自增 | 用户编号 |
| UserName | NVARCHAR(50) | 唯一，非空 | 登录账号 |
| PasswordHash | NVARCHAR(255) | 非空 | 登录密码或密码哈希 |
| RealName | NVARCHAR(50) | 可空 | 真实姓名 |
| NickName | NVARCHAR(50) | 可空 | 昵称 |
| Email | NVARCHAR(100) | 唯一，非空 | 邮箱 |
| Phone | NVARCHAR(20) | 可空 | 手机号 |
| AvatarUrl | NVARCHAR(255) | 可空 | 头像地址 |
| Role | NVARCHAR(20) | 非空 | 角色，User 或 Admin |
| IsEnabled | BIT | 非空 | 账号是否启用 |
| ReminderPreference | NVARCHAR(50) | 非空 | 提醒偏好 |
| CreatedAt | DATETIME2(0) | 非空 | 创建时间 |
| UpdatedAt | DATETIME2(0) | 可空 | 更新时间 |
| LastLoginAt | DATETIME2(0) | 可空 | 最近登录时间 |

## 2. Pets 宠物档案表

| 字段名 | 类型 | 约束 | 含义 |
|---|---|---|---|
| PetId | INT | 主键，自增 | 宠物编号 |
| UserId | INT | 外键，非空 | 所属用户 |
| PetName | NVARCHAR(50) | 非空 | 宠物名称 |
| Species | NVARCHAR(30) | 非空 | 宠物类型，如猫、狗 |
| Breed | NVARCHAR(50) | 可空 | 品种 |
| Gender | NVARCHAR(10) | 非空 | 性别 |
| Birthday | DATE | 可空 | 出生日期 |
| Age | INT | 可空 | 年龄 |
| WeightKg | DECIMAL(6,2) | 可空 | 体重，单位 kg |
| Color | NVARCHAR(30) | 可空 | 毛色 |
| PhotoUrl | NVARCHAR(255) | 可空 | 宠物照片地址 |
| Description | NVARCHAR(500) | 可空 | 备注描述 |
| IsDeleted | BIT | 非空 | 是否逻辑删除 |
| CreatedAt | DATETIME2(0) | 非空 | 创建时间 |
| UpdatedAt | DATETIME2(0) | 可空 | 更新时间 |

## 3. HealthRecords 健康指标记录表

| 字段名 | 类型 | 约束 | 含义 |
|---|---|---|---|
| HealthRecordId | INT | 主键，自增 | 健康记录编号 |
| PetId | INT | 外键，非空 | 所属宠物 |
| RecordDate | DATE | 非空 | 记录日期 |
| WeightKg | DECIMAL(6,2) | 可空 | 体重 |
| Temperature | DECIMAL(4,1) | 可空 | 体温 |
| Appetite | NVARCHAR(30) | 可空 | 饮食情况 |
| ExerciseMinutes | INT | 可空 | 运动时长 |
| SleepHours | DECIMAL(4,1) | 可空 | 睡眠时长 |
| Mood | NVARCHAR(30) | 可空 | 精神状态 |
| Symptom | NVARCHAR(500) | 可空 | 症状描述 |
| IsAbnormal | BIT | 非空 | 是否异常 |
| AbnormalMessage | NVARCHAR(500) | 可空 | 异常提示 |
| Remark | NVARCHAR(500) | 可空 | 备注 |
| CreatedAt | DATETIME2(0) | 非空 | 创建时间 |

## 4. MedicalHistories 病史记录表

| 字段名 | 类型 | 约束 | 含义 |
|---|---|---|---|
| MedicalHistoryId | INT | 主键，自增 | 病史记录编号 |
| PetId | INT | 外键，非空 | 所属宠物 |
| VisitDate | DATE | 非空 | 就诊日期 |
| HospitalName | NVARCHAR(100) | 可空 | 医院名称 |
| DoctorName | NVARCHAR(50) | 可空 | 医生姓名 |
| DiseaseName | NVARCHAR(100) | 非空 | 疾病名称 |
| Symptom | NVARCHAR(500) | 可空 | 症状 |
| Diagnosis | NVARCHAR(500) | 可空 | 诊断结果 |
| Medicine | NVARCHAR(500) | 可空 | 用药信息 |
| Treatment | NVARCHAR(500) | 可空 | 治疗方案 |
| Cost | DECIMAL(10,2) | 可空 | 就诊费用 |
| NextVisitDate | DATE | 可空 | 下次复诊日期 |
| AttachmentUrl | NVARCHAR(255) | 可空 | 附件地址 |
| Remark | NVARCHAR(500) | 可空 | 备注 |
| CreatedAt | DATETIME2(0) | 非空 | 创建时间 |

## 5. VaccineRecords 疫苗接种记录表

| 字段名 | 类型 | 约束 | 含义 |
|---|---|---|---|
| VaccineRecordId | INT | 主键，自增 | 疫苗记录编号 |
| PetId | INT | 外键，非空 | 所属宠物 |
| VaccineName | NVARCHAR(100) | 非空 | 疫苗名称 |
| VaccinationDate | DATE | 非空 | 接种日期 |
| NextVaccinationDate | DATE | 可空 | 下次接种日期 |
| HospitalName | NVARCHAR(100) | 可空 | 接种机构 |
| BatchNo | NVARCHAR(50) | 可空 | 疫苗批号 |
| ReminderEnabled | BIT | 非空 | 是否开启提醒 |
| Remark | NVARCHAR(500) | 可空 | 备注 |
| CreatedAt | DATETIME2(0) | 非空 | 创建时间 |

## 6. DewormRecords 驱虫记录表

| 字段名 | 类型 | 约束 | 含义 |
|---|---|---|---|
| DewormRecordId | INT | 主键，自增 | 驱虫记录编号 |
| PetId | INT | 外键，非空 | 所属宠物 |
| DewormType | NVARCHAR(20) | 非空 | 驱虫类型 |
| MedicineName | NVARCHAR(100) | 非空 | 药物名称 |
| DewormDate | DATE | 非空 | 驱虫日期 |
| NextDewormDate | DATE | 可空 | 下次驱虫日期 |
| Dosage | NVARCHAR(50) | 可空 | 用量 |
| ReminderEnabled | BIT | 非空 | 是否开启提醒 |
| Remark | NVARCHAR(500) | 可空 | 备注 |
| CreatedAt | DATETIME2(0) | 非空 | 创建时间 |

## 7. Reminders 提醒信息表

| 字段名 | 类型 | 约束 | 含义 |
|---|---|---|---|
| ReminderId | INT | 主键，自增 | 提醒编号 |
| UserId | INT | 外键，非空 | 接收用户 |
| PetId | INT | 外键，可空 | 相关宠物 |
| ReminderType | NVARCHAR(30) | 非空 | 提醒类型 |
| Title | NVARCHAR(100) | 非空 | 提醒标题 |
| Content | NVARCHAR(500) | 可空 | 提醒内容 |
| RemindAt | DATETIME2(0) | 非空 | 提醒时间 |
| Status | NVARCHAR(20) | 非空 | 提醒状态 |
| SourceTable | NVARCHAR(50) | 可空 | 来源表 |
| SourceId | INT | 可空 | 来源记录编号 |
| CreatedAt | DATETIME2(0) | 非空 | 创建时间 |
| SentAt | DATETIME2(0) | 可空 | 发送时间 |

## 8. AiConsultations AI 咨询记录表

| 字段名 | 类型 | 约束 | 含义 |
|---|---|---|---|
| AiConsultationId | INT | 主键，自增 | AI 咨询编号 |
| UserId | INT | 外键，非空 | 咨询用户 |
| PetId | INT | 外键，可空 | 相关宠物 |
| Question | NVARCHAR(1000) | 非空 | 用户问题 |
| Answer | NVARCHAR(MAX) | 非空 | AI 回复 |
| ConsultationType | NVARCHAR(30) | 非空 | 咨询类型 |
| ModelName | NVARCHAR(100) | 可空 | AI 模型名称 |
| IsRuleBased | BIT | 非空 | 是否为规则库回复 |
| SafetyNotice | NVARCHAR(300) | 非空 | 安全提示 |
| CreatedAt | DATETIME2(0) | 非空 | 创建时间 |

## 9. Notices 系统公告表

| 字段名 | 类型 | 约束 | 含义 |
|---|---|---|---|
| NoticeId | INT | 主键，自增 | 公告编号 |
| AdminUserId | INT | 外键，非空 | 发布管理员 |
| Title | NVARCHAR(100) | 非空 | 公告标题 |
| Content | NVARCHAR(MAX) | 非空 | 公告内容 |
| NoticeType | NVARCHAR(30) | 非空 | 公告类型 |
| IsPublished | BIT | 非空 | 是否发布 |
| PublishedAt | DATETIME2(0) | 可空 | 发布时间 |
| CreatedAt | DATETIME2(0) | 非空 | 创建时间 |
| UpdatedAt | DATETIME2(0) | 可空 | 更新时间 |
