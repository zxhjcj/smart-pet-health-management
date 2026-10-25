/*
  智能宠物健康管理系统数据库脚本
  数据库类型：SQL Server
  说明：首次执行会创建数据库和业务表；不会删除已有表或已有数据。
*/

IF DB_ID(N'SmartPetHealthDb') IS NULL
BEGIN
    CREATE DATABASE SmartPetHealthDb;
END
GO

USE SmartPetHealthDb;
GO

IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users
    (
        UserId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        UserName NVARCHAR(50) NOT NULL,
        PasswordHash NVARCHAR(255) NOT NULL,
        RealName NVARCHAR(50) NULL,
        NickName NVARCHAR(50) NULL,
        Email NVARCHAR(100) NOT NULL,
        Phone NVARCHAR(20) NULL,
        AvatarUrl NVARCHAR(255) NULL,
        Role NVARCHAR(20) NOT NULL CONSTRAINT DF_Users_Role DEFAULT N'User',
        IsEnabled BIT NOT NULL CONSTRAINT DF_Users_IsEnabled DEFAULT 1,
        ReminderPreference NVARCHAR(50) NOT NULL CONSTRAINT DF_Users_ReminderPreference DEFAULT N'站内提醒',
        CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAt DATETIME2(0) NULL,
        LastLoginAt DATETIME2(0) NULL,
        CONSTRAINT UQ_Users_UserName UNIQUE (UserName),
        CONSTRAINT UQ_Users_Email UNIQUE (Email),
        CONSTRAINT CK_Users_Role CHECK (Role IN (N'User', N'Admin'))
    );
END
GO

IF OBJECT_ID(N'dbo.Pets', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Pets
    (
        PetId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        UserId INT NOT NULL,
        PetName NVARCHAR(50) NOT NULL,
        Species NVARCHAR(30) NOT NULL,
        Breed NVARCHAR(50) NULL,
        Gender NVARCHAR(10) NOT NULL CONSTRAINT DF_Pets_Gender DEFAULT N'未知',
        Birthday DATE NULL,
        Age INT NULL,
        WeightKg DECIMAL(6,2) NULL,
        Color NVARCHAR(30) NULL,
        PhotoUrl NVARCHAR(255) NULL,
        Description NVARCHAR(500) NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_Pets_IsDeleted DEFAULT 0,
        CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Pets_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAt DATETIME2(0) NULL,
        CONSTRAINT FK_Pets_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
        CONSTRAINT CK_Pets_Gender CHECK (Gender IN (N'公', N'母', N'未知')),
        CONSTRAINT CK_Pets_Age CHECK (Age IS NULL OR Age >= 0),
        CONSTRAINT CK_Pets_WeightKg CHECK (WeightKg IS NULL OR WeightKg > 0)
    );
END
GO

IF OBJECT_ID(N'dbo.HealthRecords', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.HealthRecords
    (
        HealthRecordId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        PetId INT NOT NULL,
        RecordDate DATE NOT NULL,
        WeightKg DECIMAL(6,2) NULL,
        Temperature DECIMAL(4,1) NULL,
        Appetite NVARCHAR(30) NULL,
        ExerciseMinutes INT NULL,
        SleepHours DECIMAL(4,1) NULL,
        Mood NVARCHAR(30) NULL,
        Symptom NVARCHAR(500) NULL,
        IsAbnormal BIT NOT NULL CONSTRAINT DF_HealthRecords_IsAbnormal DEFAULT 0,
        AbnormalMessage NVARCHAR(500) NULL,
        Remark NVARCHAR(500) NULL,
        CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_HealthRecords_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_HealthRecords_Pets FOREIGN KEY (PetId) REFERENCES dbo.Pets(PetId),
        CONSTRAINT CK_HealthRecords_WeightKg CHECK (WeightKg IS NULL OR WeightKg > 0),
        CONSTRAINT CK_HealthRecords_Temperature CHECK (Temperature IS NULL OR Temperature BETWEEN 30.0 AND 45.0),
        CONSTRAINT CK_HealthRecords_ExerciseMinutes CHECK (ExerciseMinutes IS NULL OR ExerciseMinutes >= 0)
    );
END
GO

IF OBJECT_ID(N'dbo.MedicalHistories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MedicalHistories
    (
        MedicalHistoryId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        PetId INT NOT NULL,
        VisitDate DATE NOT NULL,
        HospitalName NVARCHAR(100) NULL,
        DoctorName NVARCHAR(50) NULL,
        DiseaseName NVARCHAR(100) NOT NULL,
        Symptom NVARCHAR(500) NULL,
        Diagnosis NVARCHAR(500) NULL,
        Medicine NVARCHAR(500) NULL,
        Treatment NVARCHAR(500) NULL,
        Cost DECIMAL(10,2) NULL,
        NextVisitDate DATE NULL,
        AttachmentUrl NVARCHAR(255) NULL,
        Remark NVARCHAR(500) NULL,
        CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_MedicalHistories_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_MedicalHistories_Pets FOREIGN KEY (PetId) REFERENCES dbo.Pets(PetId),
        CONSTRAINT CK_MedicalHistories_Cost CHECK (Cost IS NULL OR Cost >= 0)
    );
END
GO

IF OBJECT_ID(N'dbo.VaccineRecords', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.VaccineRecords
    (
        VaccineRecordId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        PetId INT NOT NULL,
        VaccineName NVARCHAR(100) NOT NULL,
        VaccinationDate DATE NOT NULL,
        NextVaccinationDate DATE NULL,
        HospitalName NVARCHAR(100) NULL,
        BatchNo NVARCHAR(50) NULL,
        ReminderEnabled BIT NOT NULL CONSTRAINT DF_VaccineRecords_ReminderEnabled DEFAULT 1,
        Remark NVARCHAR(500) NULL,
        CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_VaccineRecords_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_VaccineRecords_Pets FOREIGN KEY (PetId) REFERENCES dbo.Pets(PetId)
    );
END
GO

IF OBJECT_ID(N'dbo.DewormRecords', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DewormRecords
    (
        DewormRecordId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        PetId INT NOT NULL,
        DewormType NVARCHAR(20) NOT NULL,
        MedicineName NVARCHAR(100) NOT NULL,
        DewormDate DATE NOT NULL,
        NextDewormDate DATE NULL,
        Dosage NVARCHAR(50) NULL,
        ReminderEnabled BIT NOT NULL CONSTRAINT DF_DewormRecords_ReminderEnabled DEFAULT 1,
        Remark NVARCHAR(500) NULL,
        CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_DewormRecords_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_DewormRecords_Pets FOREIGN KEY (PetId) REFERENCES dbo.Pets(PetId),
        CONSTRAINT CK_DewormRecords_DewormType CHECK (DewormType IN (N'体内', N'体外', N'体内外'))
    );
END
GO

IF OBJECT_ID(N'dbo.Reminders', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Reminders
    (
        ReminderId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        UserId INT NOT NULL,
        PetId INT NULL,
        ReminderType NVARCHAR(30) NOT NULL,
        Title NVARCHAR(100) NOT NULL,
        Content NVARCHAR(500) NULL,
        RemindAt DATETIME2(0) NOT NULL,
        Status NVARCHAR(20) NOT NULL CONSTRAINT DF_Reminders_Status DEFAULT N'Pending',
        SourceTable NVARCHAR(50) NULL,
        SourceId INT NULL,
        CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Reminders_CreatedAt DEFAULT SYSUTCDATETIME(),
        SentAt DATETIME2(0) NULL,
        CONSTRAINT FK_Reminders_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
        CONSTRAINT FK_Reminders_Pets FOREIGN KEY (PetId) REFERENCES dbo.Pets(PetId),
        CONSTRAINT CK_Reminders_ReminderType CHECK (ReminderType IN (N'疫苗', N'驱虫', N'体检', N'健康异常', N'其他')),
        CONSTRAINT CK_Reminders_Status CHECK (Status IN (N'Pending', N'Sent', N'Read', N'Canceled'))
    );
END
GO

IF OBJECT_ID(N'dbo.AiConsultations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AiConsultations
    (
        AiConsultationId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        UserId INT NOT NULL,
        PetId INT NULL,
        Question NVARCHAR(1000) NOT NULL,
        Answer NVARCHAR(MAX) NOT NULL,
        ConsultationType NVARCHAR(30) NOT NULL CONSTRAINT DF_AiConsultations_ConsultationType DEFAULT N'智能问答',
        ModelName NVARCHAR(100) NULL,
        IsRuleBased BIT NOT NULL CONSTRAINT DF_AiConsultations_IsRuleBased DEFAULT 0,
        SafetyNotice NVARCHAR(300) NOT NULL CONSTRAINT DF_AiConsultations_SafetyNotice DEFAULT N'系统建议仅供参考，严重情况请及时就医。',
        CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_AiConsultations_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_AiConsultations_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
        CONSTRAINT FK_AiConsultations_Pets FOREIGN KEY (PetId) REFERENCES dbo.Pets(PetId),
        CONSTRAINT CK_AiConsultations_ConsultationType CHECK (ConsultationType IN (N'智能问答', N'症状分析', N'健康评估', N'养宠建议'))
    );
END
GO

IF OBJECT_ID(N'dbo.Notices', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Notices
    (
        NoticeId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        AdminUserId INT NOT NULL,
        Title NVARCHAR(100) NOT NULL,
        Content NVARCHAR(MAX) NOT NULL,
        NoticeType NVARCHAR(30) NOT NULL CONSTRAINT DF_Notices_NoticeType DEFAULT N'系统公告',
        IsPublished BIT NOT NULL CONSTRAINT DF_Notices_IsPublished DEFAULT 0,
        PublishedAt DATETIME2(0) NULL,
        CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Notices_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAt DATETIME2(0) NULL,
        CONSTRAINT FK_Notices_AdminUser FOREIGN KEY (AdminUserId) REFERENCES dbo.Users(UserId)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Pets_UserId' AND object_id = OBJECT_ID(N'dbo.Pets'))
    CREATE INDEX IX_Pets_UserId ON dbo.Pets(UserId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_HealthRecords_PetId_RecordDate' AND object_id = OBJECT_ID(N'dbo.HealthRecords'))
    CREATE INDEX IX_HealthRecords_PetId_RecordDate ON dbo.HealthRecords(PetId, RecordDate DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_MedicalHistories_PetId_VisitDate' AND object_id = OBJECT_ID(N'dbo.MedicalHistories'))
    CREATE INDEX IX_MedicalHistories_PetId_VisitDate ON dbo.MedicalHistories(PetId, VisitDate DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_VaccineRecords_PetId_NextDate' AND object_id = OBJECT_ID(N'dbo.VaccineRecords'))
    CREATE INDEX IX_VaccineRecords_PetId_NextDate ON dbo.VaccineRecords(PetId, NextVaccinationDate);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DewormRecords_PetId_NextDate' AND object_id = OBJECT_ID(N'dbo.DewormRecords'))
    CREATE INDEX IX_DewormRecords_PetId_NextDate ON dbo.DewormRecords(PetId, NextDewormDate);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Reminders_UserId_RemindAt_Status' AND object_id = OBJECT_ID(N'dbo.Reminders'))
    CREATE INDEX IX_Reminders_UserId_RemindAt_Status ON dbo.Reminders(UserId, RemindAt, Status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_AiConsultations_UserId_CreatedAt' AND object_id = OBJECT_ID(N'dbo.AiConsultations'))
    CREATE INDEX IX_AiConsultations_UserId_CreatedAt ON dbo.AiConsultations(UserId, CreatedAt DESC);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE UserName = N'admin')
BEGIN
    INSERT INTO dbo.Users
    (
        UserName,
        PasswordHash,
        RealName,
        NickName,
        Email,
        Role,
        IsEnabled
    )
    VALUES
    (
        N'admin',
        N'admin123',
        N'系统管理员',
        N'管理员',
        N'admin@example.com',
        N'Admin',
        1
    );
END
GO
